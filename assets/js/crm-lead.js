/* crm-lead.js — schickt jede Website-Anfrage zusätzlich als Lead ins CRM.
 * Die bestehende EmailJS-Logik in main.js bleibt unverändert; dieses Skript lauscht nur mit.
 * Einbinden: <script src="/assets/js/crm-lead.js" defer></script> direkt nach main.js.
 * Der Key ist der öffentliche Supabase-Key: er darf nur die Funktion submit_lead aufrufen. */
(function () {
  var ENDPOINT = 'https://mvgqksltpcqflazrjamx.supabase.co/rest/v1/rpc/submit_lead';
  var KEY = 'sb_publishable_5nwJrgDdH6Hxrk6YTwuROg_h6JXM9ek';
  var COOLDOWN_MS = 30000;

  var form = document.querySelector('.contact-form');
  if (!form) return;

  form.addEventListener('submit', function () {
    try {
      // Dieselben Vorprüfungen wie main.js, damit nur echte, gültige Anfragen ins CRM gehen
      if (!form.checkValidity()) return;
      var f = new FormData(form);
      if (f.get('website')) return; // Honeypot

      var now = Date.now();
      var last = +sessionStorage.getItem('adf24_crm_last') || 0;
      if (now - last < COOLDOWN_MS) return;
      sessionStorage.setItem('adf24_crm_last', String(now));

      fetch(ENDPOINT, {
        method: 'POST',
        keepalive: true,
        headers: { 'content-type': 'application/json', apikey: KEY },
        body: JSON.stringify({
          p_first: f.get('vorname') || '',
          p_last: f.get('nachname') || '',
          p_email: f.get('email') || '',
          p_project_type: f.get('projekttyp') || '',
          p_message: f.get('nachricht') || '',
          p_hp: '',
        }),
      }).catch(function () { /* Die Mail über EmailJS ist der Hauptweg; CRM-Fehler bleiben still */ });
    } catch (e) { /* nie das Formular stören */ }
  });
})();
