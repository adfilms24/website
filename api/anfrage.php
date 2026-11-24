<?php
/* api/anfrage.php — Kontaktformular auf Infomaniak (PHP). Gleiches Verhalten wie api/anfrage.js auf Vercel.
 *
 * GET  → { enabled, sitekey }
 * POST → prüft das Turnstile-Token, schickt die Anfrage per Resend an info@ und legt sie im CRM ab.
 *
 * Schlüssel kommen aus api/config.php. Diese Datei ist nicht im Repo: der Deploy-Workflow schreibt sie aus den
 * GitHub-Secrets TURNSTILE_SITE_KEY, TURNSTILE_SECRET_KEY und RESEND_API_KEY. Direkter Aufruf ist per .htaccess gesperrt. */

const SITEVERIFY = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';
const RESEND = 'https://api.resend.com/emails';
const CRM = 'https://mvgqksltpcqflazrjamx.supabase.co/rest/v1/rpc/';
// Öffentlicher Supabase-Schlüssel; darf nur submit_inquiry und submit_lead aufrufen
const CRM_KEY = 'sb_publishable_5nwJrgDdH6Hxrk6YTwuROg_h6JXM9ek';
const MAIL = 'info@adfilms24.ch';
const LIMITS = [
  'vorname' => 80, 'nachname' => 80, 'email' => 200, 'telefon' => 50, 'firma' => 150, 'branche' => 100, 'projekttyp' => 100,
  'budget' => 60, 'zeitrahmen' => 60, 'termin' => 60, 'quelle' => 80, 'nachricht' => 5000, 'website' => 200,
];
const ATTR_KEYS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'landing', 'referrer'];
const RATE_LIMIT = 5;
const RATE_WINDOW = 600;

function out($status, $data, $extra = []) {
  http_response_code($status);
  header('content-type: application/json; charset=utf-8');
  header('cache-control: no-store');
  foreach ($extra as $k => $v) header("$k: $v");
  echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

function config() {
  $c = [];
  if (is_file(__DIR__ . '/config.php')) { define('ANFRAGE', 1); $c = include __DIR__ . '/config.php'; }
  $site = (string)($c['TURNSTILE_SITE_KEY'] ?? ''); $secret = (string)($c['TURNSTILE_SECRET_KEY'] ?? '');
  $resend = (string)($c['RESEND_API_KEY'] ?? '');
  return ['site' => $site, 'secret' => $secret, 'resend' => $resend, 'enabled' => $site !== '' && $secret !== '' && $resend !== ''];
}

function clean($v, $max) {
  if (is_array($v) || is_object($v)) $v = '';
  return mb_substr(trim(str_replace("\0", '', (string)($v ?? ''))), 0, $max);
}

function read_fields($raw) {
  $f = [];
  foreach (LIMITS as $k => $max) $f[$k] = clean(is_array($raw) ? ($raw[$k] ?? '') : '', $max);
  return $f;
}

function read_attr($raw) {
  $a = [];
  foreach (ATTR_KEYS as $k) $a[$k] = clean(is_array($raw) ? ($raw[$k] ?? '') : '', 300);
  return $a;
}

function client_ip() {
  $xf = trim(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '')[0]);
  return $xf !== '' ? $xf : ($_SERVER['HTTP_X_REAL_IP'] ?? ($_SERVER['REMOTE_ADDR'] ?? ''));
}

// Max. 5 Anfragen pro IP in 10 Minuten; gespeichert als gehashte IP im temporären Ordner des Servers
function limited($ip) {
  if ($ip === '') return false;
  $file = sys_get_temp_dir() . '/adf-anfrage-' . hash('sha256', 'adf' . $ip);
  $now = time();
  $hits = array_filter(array_map('intval', @file($file, FILE_IGNORE_NEW_LINES) ?: []), fn($t) => $now - $t < RATE_WINDOW);
  $hits[] = $now;
  @file_put_contents($file, implode("\n", $hits), LOCK_EX);
  return count($hits) > RATE_LIMIT;
}

function http_post($url, $body, $headers) {
  $ch = curl_init($url);
  curl_setopt_array($ch, [
    CURLOPT_POST => true, CURLOPT_POSTFIELDS => $body, CURLOPT_HTTPHEADER => $headers,
    CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 15,
  ]);
  $res = curl_exec($ch);
  $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
  curl_close($ch);
  return [$code, $res === false ? '' : $res];
}

function verify_token($secret, $token, $ip) {
  $p = ['secret' => $secret, 'response' => $token];
  if ($ip !== '') $p['remoteip'] = $ip;
  [, $res] = http_post(SITEVERIFY, http_build_query($p), ['content-type: application/x-www-form-urlencoded']);
  $d = json_decode($res, true);
  return is_array($d) && ($d['success'] ?? false) === true;
}

function mail_text($f, $lang, $page) {
  $rows = [
    'Name' => trim($f['vorname'] . ' ' . $f['nachname']), 'E-Mail' => $f['email'], 'Telefon' => $f['telefon'],
    'Firma' => $f['firma'], 'Branche' => $f['branche'], 'Projekttyp' => $f['projekttyp'], 'Budget' => $f['budget'],
    'Zeitrahmen' => $f['zeitrahmen'], 'Wunschtermin' => $f['termin'], 'Gefunden über' => $f['quelle'],
    'Sprache' => $lang, 'Seite' => $page,
  ];
  $head = [];
  foreach ($rows as $k => $v) if ($v !== '') $head[] = "$k: $v";
  $msg = $f['nachricht'] !== '' ? $f['nachricht'] : '(keine)';
  return implode("\n", $head) . "\n\nNachricht:\n$msg\n\n— Gesendet über das Kontaktformular auf adfilms24.ch (Spam-Schutz bestanden).";
}

function send_mail($key, $f, $lang, $page) {
  $name = trim($f['vorname'] . ' ' . $f['nachname']);
  $subject = preg_replace('/[\r\n]+/', ' ', 'Neue Anfrage: ' . $name . ($f['projekttyp'] !== '' ? ' – ' . $f['projekttyp'] : ''));
  [$code] = http_post(RESEND, json_encode([
    'from' => 'ADFilms24 Website <' . MAIL . '>', 'to' => [MAIL], 'reply_to' => $f['email'],
    'subject' => $subject, 'text' => mail_text($f, $lang, $page),
  ], JSON_UNESCAPED_UNICODE), ["authorization: Bearer $key", 'content-type: application/json']);
  return $code >= 200 && $code < 300;
}

function save_to_crm($f, $a) {
  $post = fn($fn, $body) => http_post(CRM . $fn, json_encode($body, JSON_UNESCAPED_UNICODE),
    ['content-type: application/json', 'apikey: ' . CRM_KEY])[0];
  $timeframe = implode(' · ', array_filter([$f['zeitrahmen'], $f['termin']], 'strlen'));
  $code = $post('submit_inquiry', [
    'p_first' => $f['vorname'], 'p_last' => $f['nachname'], 'p_email' => $f['email'], 'p_phone' => $f['telefon'],
    'p_company' => $f['firma'], 'p_project_type' => $f['projekttyp'], 'p_budget' => $f['budget'], 'p_timeframe' => $timeframe,
    'p_industry' => $f['branche'], 'p_message' => $f['nachricht'], 'p_found_via' => $f['quelle'],
    'p_utm_source' => $a['utm_source'], 'p_utm_medium' => $a['utm_medium'], 'p_utm_campaign' => $a['utm_campaign'],
    'p_utm_content' => $a['utm_content'], 'p_landing' => $a['landing'],
    'p_referrer' => $a['referrer'] !== '' ? 'https://' . $a['referrer'] : '', 'p_hp' => '',
  ]);
  if ($code === 404) {
    $message = implode("\n", array_filter([$f['nachricht'],
      $f['firma'] !== '' ? "Firma: {$f['firma']}" : '', $f['branche'] !== '' ? "Branche: {$f['branche']}" : '',
      $f['telefon'] !== '' ? "Telefon: {$f['telefon']}" : '', $f['budget'] !== '' ? "Budget: {$f['budget']}" : '',
      $timeframe !== '' ? "Zeitrahmen: $timeframe" : '', $f['quelle'] !== '' ? "Gefunden über: {$f['quelle']}" : '',
    ], 'strlen'));
    $code = $post('submit_lead', [
      'p_first' => $f['vorname'], 'p_last' => $f['nachname'], 'p_email' => $f['email'],
      'p_project_type' => $f['projekttyp'], 'p_message' => $message, 'p_hp' => '',
    ]);
  }
  return $code >= 200 && $code < 300;
}

$cfg = config();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'GET') out(200, ['enabled' => $cfg['enabled'], 'sitekey' => $cfg['enabled'] ? $cfg['site'] : '']);
if ($method !== 'POST') out(405, ['error' => 'method'], ['allow' => 'GET, POST']);
if (!$cfg['enabled']) out(503, ['error' => 'not_configured']);
if (limited(client_ip())) out(429, ['error' => 'rate'], ['retry-after' => '600']);

$body = json_decode(file_get_contents('php://input') ?: '', true);
if (!is_array($body) || !is_string($body['token'] ?? null) || $body['token'] === '' || strlen($body['token']) > 4096) {
  out(400, ['error' => 'token']);
}
if (!verify_token($cfg['secret'], $body['token'], client_ip())) out(403, ['error' => 'challenge']);

$f = read_fields($body['fields'] ?? null);
// Honeypot: still annehmen, aber nichts senden
if ($f['website'] !== '') out(200, ['ok' => true]);
if ($f['vorname'] === '' || $f['nachname'] === '' || !preg_match('/^[^\s@]+@[^\s@]+\.[^\s@]+$/', $f['email'])) {
  out(400, ['error' => 'fields']);
}
$lang = clean($body['lang'] ?? '', 5); if ($lang === '') $lang = 'de';
$page = clean($_SERVER['HTTP_REFERER'] ?? '', 300);

$mailed = send_mail($cfg['resend'], $f, $lang, $page);
$saved = save_to_crm($f, read_attr($body['attr'] ?? null));
// Die Mail ist der Hauptweg; landet die Anfrage wenigstens im CRM, gilt sie trotzdem als angekommen
if (!$mailed && !$saved) out(502, ['error' => 'delivery']);
out(200, ['ok' => true, 'mailed' => $mailed, 'saved' => $saved]);
