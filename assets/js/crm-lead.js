/* crm-lead.js — legt eine Website-Anfrage als Lead im CRM an, wenn das Formular über EmailJS sendet.
 * Läuft der unsichtbare Spam-Check (api/anfrage.js), speichert der Server die Anfrage selbst und dieses Skript bleibt still.
 * main.js ruft window.adf24CrmLead(form) auf. Einbinden: <script src="/assets/js/crm-lead.js" defer></script> nach main.js.
 * Der Key ist der öffentliche Supabase-Key: er darf nur die Funktionen submit_inquiry und submit_lead aufrufen.
 * submit_inquiry nimmt Budget, Zeitrahmen, Branche und die Herkunft (attribution.js) mit; fehlt sie in der
 * Datenbank noch, geht die Anfrage wie bisher über submit_lead. */
(function () {
  var BASE = 'https://mvgqksltpcqflazrjamx.supabase.co/rest/v1/rpc/';
  var KEY = 'sb_publishable_5nwJrgDdH6Hxrk6YTwuROg_h6JXM9ek';
  var COOLDOWN_MS = 30000;

  var form = document.querySelector('.contact-form');
  if (!form) return;

  function post(fn, body) {
    return fetch(BASE + fn, {
      method: 'POST',
      keepalive: true,
      headers: { 'content-type': 'application/json', apikey: KEY },
      body: JSON.stringify(body),
    });
  }

  function attribution() {
    try { return JSON.parse(sessionStorage.getItem('adf24_attr') || '{}') || {}; } catch (e) { return {}; }
  }

  window.adf24CrmLead = function () {
    try {
      // Dieselben Vorprüfungen wie main.js, damit nur echte, gültige Anfragen ins CRM gehen
      if (!form.checkValidity()) return;
      var f = new FormData(form);
      if (f.get('website')) return; // Honeypot

      var now = Date.now();
      var last = +sessionStorage.getItem('adf24_crm_last') || 0;
      if (now - last < COOLDOWN_MS) return;
      sessionStorage.setItem('adf24_crm_last', String(now));

      var a = attribution();
      var val = function (k) { return f.get(k) || ''; };
      var timeframe = [val('zeitrahmen'), val('termin')].filter(Boolean).join(' · ');
      var inquiry = {
        p_first: val('vorname'),
        p_last: val('nachname'),
        p_email: val('email'),
        p_phone: val('telefon'),
        p_company: val('firma'),
        p_project_type: val('projekttyp'),
        p_budget: val('budget'),
        p_timeframe: timeframe,
        p_industry: val('branche'),
        p_message: val('nachricht'),
        p_found_via: val('quelle'),
        p_utm_source: a.utm_source || '',
        p_utm_medium: a.utm_medium || '',
        p_utm_campaign: a.utm_campaign || '',
        p_utm_content: a.utm_content || '',
        p_landing: a.landing || '',
        p_referrer: a.referrer ? 'https://' + a.referrer : '',
        p_hp: '',
      };
      var legacy = {
        p_first: inquiry.p_first,
        p_last: inquiry.p_last,
        p_email: inquiry.p_email,
        p_project_type: inquiry.p_project_type,
        p_message: [val('nachricht'),
          val('firma') ? 'Firma: ' + val('firma') : '',
          val('branche') ? 'Branche: ' + val('branche') : '',
          val('telefon') ? 'Telefon: ' + val('telefon') : '',
          val('budget') ? 'Budget: ' + val('budget') : '',
          timeframe ? 'Zeitrahmen: ' + timeframe : '',
          val('quelle') ? 'Gefunden über: ' + val('quelle') : ''].filter(Boolean).join('\n'),
        p_hp: '',
      };

      // 404 = submit_inquiry ist in der Datenbank noch nicht angelegt → altes Verfahren
      post('submit_inquiry', inquiry)
        .then(function (res) { if (res.status === 404) return post('submit_lead', legacy); })
        .catch(function () { /* Die Mail über EmailJS ist der Hauptweg; CRM-Fehler bleiben still */ });
    } catch (e) { /* nie das Formular stören */ }
  };
})();
