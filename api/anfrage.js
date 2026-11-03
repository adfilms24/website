/* api/anfrage.js — nimmt Anfragen aus dem Kontaktformular an (Vercel-Funktion).
 *
 * GET  → { enabled, sitekey }: ob der Spam-Schutz eingerichtet ist und welcher öffentliche Turnstile-Schlüssel gilt.
 * POST → prüft das Turnstile-Token bei Cloudflare, schickt die Anfrage per Resend an info@ und legt sie im CRM ab.
 *
 * Umgebungsvariablen in Vercel (Projekt der Website):
 *   TURNSTILE_SITE_KEY    öffentlicher Schlüssel des Turnstile-Widgets
 *   TURNSTILE_SECRET_KEY  geheimer Schlüssel des Widgets
 *   RESEND_API_KEY        Resend-Schlüssel mit Senderecht für adfilms24.ch
 * Fehlt einer davon, antwortet die Funktion mit enabled:false bzw. 503 und das Formular zeigt die Ausweichkontakte. */

const SITEVERIFY = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';
const RESEND = 'https://api.resend.com/emails';
const CRM = 'https://mvgqksltpcqflazrjamx.supabase.co/rest/v1/rpc/';
// Öffentlicher Supabase-Schlüssel; darf nur submit_inquiry und submit_lead aufrufen
const CRM_KEY = 'sb_publishable_5nwJrgDdH6Hxrk6YTwuROg_h6JXM9ek';
const MAIL = 'info@adfilms24.ch';

const LIMITS = {
  vorname: 80, nachname: 80, email: 200, telefon: 50, firma: 150, branche: 100, projekttyp: 100,
  budget: 60, zeitrahmen: 60, termin: 60, quelle: 80, nachricht: 5000, website: 200,
};
const ATTR_KEYS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'landing', 'referrer'];

function config() {
  const site = process.env.TURNSTILE_SITE_KEY || '';
  const secret = process.env.TURNSTILE_SECRET_KEY || '';
  const resend = process.env.RESEND_API_KEY || '';
  return { site, secret, resend, enabled: Boolean(site && secret && resend) };
}

function clean(v, max) {
  return String(v == null ? '' : v).replace(/\u0000/g, '').trim().slice(0, max);
}

function readFields(raw) {
  const f = {};
  for (const [k, max] of Object.entries(LIMITS)) f[k] = clean(raw && raw[k], max);
  return f;
}

function readAttr(raw) {
  const a = {};
  for (const k of ATTR_KEYS) a[k] = clean(raw && raw[k], 300);
  return a;
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function clientIp(req) {
  const xf = String(req.headers['x-forwarded-for'] || '').split(',')[0].trim();
  return xf || req.headers['x-real-ip'] || '';
}

async function verifyToken(secret, token, ip) {
  const body = new URLSearchParams({ secret, response: token });
  if (ip) body.set('remoteip', ip);
  const res = await fetch(SITEVERIFY, { method: 'POST', body });
  const data = await res.json().catch(() => ({}));
  return data && data.success === true;
}

function mailText(f, lang, page) {
  const rows = [
    ['Name', `${f.vorname} ${f.nachname}`.trim()],
    ['E-Mail', f.email],
    ['Telefon', f.telefon],
    ['Firma', f.firma],
    ['Branche', f.branche],
    ['Projekttyp', f.projekttyp],
    ['Budget', f.budget],
    ['Zeitrahmen', f.zeitrahmen],
    ['Wunschtermin', f.termin],
    ['Gefunden über', f.quelle],
    ['Sprache', lang],
    ['Seite', page],
  ].filter(([, v]) => v);
  const head = rows.map(([k, v]) => `${k}: ${v}`).join('\n');
  return `${head}\n\nNachricht:\n${f.nachricht || '(keine)'}\n\n— Gesendet über das Kontaktformular auf adfilms24.ch (Spam-Schutz bestanden).`;
}

async function sendMail(key, f, lang, page) {
  const name = `${f.vorname} ${f.nachname}`.trim();
  const subject = `Neue Anfrage: ${name}${f.projekttyp ? ' – ' + f.projekttyp : ''}`.replace(/[\r\n]+/g, ' ');
  const res = await fetch(RESEND, {
    method: 'POST',
    headers: { authorization: `Bearer ${key}`, 'content-type': 'application/json' },
    body: JSON.stringify({
      from: `ADFilms24 Website <${MAIL}>`,
      to: [MAIL],
      reply_to: f.email,
      subject,
      text: mailText(f, lang, page),
    }),
  });
  return res.ok;
}

async function saveToCrm(f, a) {
  const post = (fn, body) => fetch(CRM + fn, {
    method: 'POST',
    headers: { 'content-type': 'application/json', apikey: CRM_KEY },
    body: JSON.stringify(body),
  });
  const timeframe = [f.zeitrahmen, f.termin].filter(Boolean).join(' · ');
  const inquiry = {
    p_first: f.vorname, p_last: f.nachname, p_email: f.email, p_phone: f.telefon, p_company: f.firma,
    p_project_type: f.projekttyp, p_budget: f.budget, p_timeframe: timeframe, p_industry: f.branche,
    p_message: f.nachricht, p_found_via: f.quelle,
    p_utm_source: a.utm_source, p_utm_medium: a.utm_medium, p_utm_campaign: a.utm_campaign,
    p_utm_content: a.utm_content, p_landing: a.landing, p_referrer: a.referrer ? 'https://' + a.referrer : '',
    p_hp: '',
  };
  let res = await post('submit_inquiry', inquiry);
  if (res.status === 404) {
    const message = [f.nachricht,
      f.firma && `Firma: ${f.firma}`, f.branche && `Branche: ${f.branche}`, f.telefon && `Telefon: ${f.telefon}`,
      f.budget && `Budget: ${f.budget}`, timeframe && `Zeitrahmen: ${timeframe}`, f.quelle && `Gefunden über: ${f.quelle}`,
    ].filter(Boolean).join('\n');
    res = await post('submit_lead', {
      p_first: f.vorname, p_last: f.nachname, p_email: f.email, p_project_type: f.projekttyp, p_message: message, p_hp: '',
    });
  }
  return res.ok;
}

function parseBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  if (typeof req.body === 'string') { try { return JSON.parse(req.body); } catch (e) { return null; } }
  return null;
}

module.exports = async function handler(req, res) {
  const cfg = config();
  res.setHeader('cache-control', 'no-store');

  if (req.method === 'GET') {
    return res.status(200).json({ enabled: cfg.enabled, sitekey: cfg.enabled ? cfg.site : '' });
  }
  if (req.method !== 'POST') {
    res.setHeader('allow', 'GET, POST');
    return res.status(405).json({ error: 'method' });
  }
  if (!cfg.enabled) return res.status(503).json({ error: 'not_configured' });

  const body = parseBody(req);
  if (!body || typeof body.token !== 'string' || !body.token || body.token.length > 4096) {
    return res.status(400).json({ error: 'token' });
  }

  let human = false;
  try { human = await verifyToken(cfg.secret, body.token, clientIp(req)); } catch (e) { human = false; }
  if (!human) return res.status(403).json({ error: 'challenge' });

  const f = readFields(body.fields);
  // Honeypot: still annehmen, aber nichts senden
  if (f.website) return res.status(200).json({ ok: true });
  if (!f.vorname || !f.nachname || !EMAIL_RE.test(f.email)) return res.status(400).json({ error: 'fields' });

  const lang = clean(body.lang, 5) || 'de';
  const page = clean(req.headers.referer, 300);

  let mailed = false;
  try { mailed = await sendMail(cfg.resend, f, lang, page); } catch (e) { mailed = false; }
  let saved = false;
  try { saved = await saveToCrm(f, readAttr(body.attr)); } catch (e) { saved = false; }

  // Die Mail ist der Hauptweg; landet die Anfrage wenigstens im CRM, gilt sie trotzdem als angekommen
  if (!mailed && !saved) return res.status(502).json({ error: 'delivery' });
  return res.status(200).json({ ok: true, mailed, saved });
};
