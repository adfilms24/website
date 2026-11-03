// Tests für api/anfrage.js (node --test tests/). Netzwerk wird über ein Fake-fetch ersetzt.
const test = require('node:test');
const assert = require('node:assert');
const handler = require('../api/anfrage.js');

function fakeRes() {
  const r = { statusCode: 0, headers: {}, body: null };
  r.setHeader = (k, v) => { r.headers[k.toLowerCase()] = v; };
  r.status = (c) => { r.statusCode = c; return r; };
  r.json = (b) => { r.body = b; return r; };
  return r;
}

function req(method, body, headers = {}) {
  return { method, body, headers: { 'x-forwarded-for': '203.0.113.7, 10.0.0.1', referer: 'https://adfilms24.ch/', ...headers } };
}

const FIELDS = { vorname: 'Anna', nachname: 'Muster', email: 'anna@example.ch', projekttyp: 'Imagefilm', nachricht: 'Hallo', budget: 'CHF 2\'000–5\'000', website: '' };

function setup({ human = true, mailOk = true, crmStatus = 200 } = {}) {
  handler._resetLimit();
  const calls = [];
  global.fetch = async (url, opts) => {
    calls.push({ url, opts });
    if (url.includes('siteverify')) return { ok: true, json: async () => ({ success: human }) };
    if (url.includes('api.resend.com')) return { ok: mailOk, status: mailOk ? 200 : 500 };
    if (url.includes('/rpc/')) return { ok: crmStatus < 300, status: crmStatus };
    throw new Error('unexpected ' + url);
  };
  process.env.TURNSTILE_SITE_KEY = 'site-key';
  process.env.TURNSTILE_SECRET_KEY = 'secret-key';
  process.env.RESEND_API_KEY = 're_test';
  return calls;
}

test('ohne Schlüssel: GET meldet enabled:false, POST 503', async () => {
  setup();
  delete process.env.RESEND_API_KEY;
  let r = fakeRes(); await handler(req('GET'), r);
  assert.deepStrictEqual(r.body, { enabled: false, sitekey: '' });
  r = fakeRes(); await handler(req('POST', { token: 't', fields: FIELDS }), r);
  assert.strictEqual(r.statusCode, 503);
});

test('GET liefert den öffentlichen Schlüssel', async () => {
  setup();
  const r = fakeRes(); await handler(req('GET'), r);
  assert.deepStrictEqual(r.body, { enabled: true, sitekey: 'site-key' });
});

test('ohne Token 400, nichts wird gesendet', async () => {
  const calls = setup();
  const r = fakeRes(); await handler(req('POST', { fields: FIELDS }), r);
  assert.strictEqual(r.statusCode, 400);
  assert.strictEqual(calls.length, 0);
});

test('Check nicht bestanden: 403, keine Mail, kein CRM', async () => {
  const calls = setup({ human: false });
  const r = fakeRes(); await handler(req('POST', { token: 'bad', fields: FIELDS }), r);
  assert.strictEqual(r.statusCode, 403);
  assert.deepStrictEqual(calls.map((c) => new URL(c.url).hostname), ['challenges.cloudflare.com']);
  const sent = new URLSearchParams(calls[0].opts.body);
  assert.strictEqual(sent.get('secret'), 'secret-key');
  assert.strictEqual(sent.get('remoteip'), '203.0.113.7');
});

test('Honeypot gefüllt: 200, aber nichts gesendet', async () => {
  const calls = setup();
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: { ...FIELDS, website: 'spam.example' } }), r);
  assert.strictEqual(r.statusCode, 200);
  assert.strictEqual(calls.length, 1);
});

test('ungültige E-Mail: 400', async () => {
  setup();
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: { ...FIELDS, email: 'kein-mail' } }), r);
  assert.strictEqual(r.statusCode, 400);
});

test('gültige Anfrage: Mail an info@ mit Antwort an Absender, CRM-Eintrag', async () => {
  const calls = setup();
  const body = { token: 'ok', lang: 'de', fields: FIELDS, attr: { utm_source: 'instagram', referrer: 'instagram.com' } };
  const r = fakeRes(); await handler(req('POST', JSON.stringify(body), { 'content-type': 'application/json' }), r);
  assert.strictEqual(r.statusCode, 200);
  assert.deepStrictEqual(r.body, { ok: true, mailed: true, saved: true });
  const mail = JSON.parse(calls.find((c) => c.url.includes('resend')).opts.body);
  assert.deepStrictEqual(mail.to, ['info@adfilms24.ch']);
  assert.strictEqual(mail.reply_to, 'anna@example.ch');
  assert.strictEqual(mail.subject, 'Neue Anfrage: Anna Muster – Imagefilm');
  assert.match(mail.text, /Budget: CHF 2'000–5'000/);
  const crm = calls.find((c) => c.url.endsWith('/submit_inquiry'));
  const p = JSON.parse(crm.opts.body);
  assert.strictEqual(p.p_email, 'anna@example.ch');
  assert.strictEqual(p.p_utm_source, 'instagram');
  assert.strictEqual(p.p_referrer, 'https://instagram.com');
});

test('Zeilenumbrüche im Betreff werden entfernt', async () => {
  const calls = setup();
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: { ...FIELDS, projekttyp: 'A\r\nBcc: x@y.z' } }), r);
  const mail = JSON.parse(calls.find((c) => c.url.includes('resend')).opts.body);
  assert.ok(!/[\r\n]/.test(mail.subject));
});

test('submit_inquiry fehlt (404): Rückfall auf submit_lead', async () => {
  const calls = setup({ crmStatus: 404 });
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: FIELDS }), r);
  assert.ok(calls.some((c) => c.url.endsWith('/submit_lead')));
  assert.strictEqual(r.statusCode, 200);
});

test('Mail und CRM scheitern: 502', async () => {
  setup({ mailOk: false, crmStatus: 500 });
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: FIELDS }), r);
  assert.strictEqual(r.statusCode, 502);
});

test('andere Methoden: 405', async () => {
  setup();
  const r = fakeRes(); await handler(req('PUT'), r);
  assert.strictEqual(r.statusCode, 405);
});

test('mehr als 5 Anfragen pro IP in 10 Minuten: 429', async () => {
  const calls = setup();
  for (let i = 0; i < 5; i++) {
    const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: FIELDS }), r);
    assert.strictEqual(r.statusCode, 200);
  }
  const before = calls.length;
  const r = fakeRes(); await handler(req('POST', { token: 'ok', fields: FIELDS }), r);
  assert.strictEqual(r.statusCode, 429);
  assert.strictEqual(r.headers['retry-after'], '600');
  assert.strictEqual(calls.length, before, 'kein Turnstile-, Mail- oder CRM-Aufruf mehr');
  const other = fakeRes(); await handler(req('POST', { token: 'ok', fields: FIELDS }, { 'x-forwarded-for': '198.51.100.9' }), other);
  assert.strictEqual(other.statusCode, 200, 'andere IP nicht betroffen');
});
