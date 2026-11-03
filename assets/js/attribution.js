/* attribution.js — merkt sich für diese Sitzung, woher jemand kam (UTM-Parameter, verweisende Website, erste Seite).
 * Wird nur beim Absenden des Anfrageformulars mitgeschickt (an /api/anfrage), damit das CRM zeigt, welcher Kanal Anfragen bringt.
 * Sitzungsspeicher statt Cookie: verlässt das Gerät nicht von selbst und ist beim Schliessen des Tabs weg.
 * Erste Berührung der Sitzung zählt. Von der verweisenden Website wird nur der Hostname gespeichert. */
(function () {
  try {
    var KEY = 'adf24_attr';
    if (sessionStorage.getItem(KEY)) return;
    var p = new URLSearchParams(location.search);
    var data = { landing: location.pathname.slice(0, 300) };
    ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content'].forEach(function (k) {
      var v = p.get(k);
      if (v) data[k] = v.slice(0, 150);
    });
    if (document.referrer) {
      var host = new URL(document.referrer).hostname;
      if (host && host !== location.hostname && !/(^|\.)adfilms24\.ch$/.test(host)) data.referrer = host.slice(0, 200);
    }
    sessionStorage.setItem(KEY, JSON.stringify(data));
  } catch (e) { /* ohne Speicher einfach keine Herkunft */ }
})();
