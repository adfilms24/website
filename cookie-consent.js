/*
  Cookie-Consent-Banner für www.adfilms24.ch
  ------------------------------------------
  Aktueller Stand: Die Seite setzt keine Tracking-Cookies (nur EmailJS für
  das Kontaktformular, keine Analyse-Tools). Die Zustimmung selbst wird
  nicht als Cookie, sondern im localStorage des Browsers gespeichert.

  Sobald Analyse-Tools (z.B. Google Analytics) hinzukommen: das Lade-Skript
  in loadAnalyticsIfConsented() unten ergänzen — es wird automatisch nur
  ausgeführt, wenn "Akzeptieren" angeklickt wurde bzw. bereits wurde.
*/
(function () {
  var STORAGE_KEY = "adf24_cookie_consent"; // "accepted" | "declined"

  function loadAnalyticsIfConsented() {
    if (localStorage.getItem(STORAGE_KEY) !== "accepted") return;
    // TODO: Sobald ein Analyse-Tool eingesetzt wird (z.B. Google Analytics),
    // hier das Lade-Skript einfügen, z.B.:
    //
    // var s = document.createElement("script");
    // s.src = "https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX";
    // s.async = true;
    // document.head.appendChild(s);
    // window.dataLayer = window.dataLayer || [];
    // function gtag(){ dataLayer.push(arguments); }
    // gtag("js", new Date());
    // gtag("config", "G-XXXXXXX");
  }
  window.loadAnalyticsIfConsented = loadAnalyticsIfConsented;

  function setConsent(value) {
    try {
      localStorage.setItem(STORAGE_KEY, value);
    } catch (e) {
      /* localStorage kann in privaten Fenstern blockiert sein — Banner
         erscheint dann bei jedem Besuch erneut, kein hartes Problem. */
    }
    var el = document.getElementById("cookie-banner");
    if (el) el.remove();
    if (value === "accepted") loadAnalyticsIfConsented();
  }

  function showBanner() {
    var wrap = document.createElement("div");
    wrap.id = "cookie-banner";
    wrap.setAttribute("role", "region");
    wrap.setAttribute("aria-label", "Cookie-Hinweis");
    wrap.style.cssText =
      "position:fixed;left:1rem;right:1rem;bottom:1rem;z-index:99999;" +
      "max-width:560px;margin:0 auto;background:#0e0e0e;color:#EDE9E0;" +
      "border:1px solid rgba(255,255,255,0.16);border-radius:4px;" +
      "padding:1.25rem 1.5rem;font-family:'JetBrains Mono','Courier New',monospace;" +
      "font-size:0.8rem;line-height:1.5;box-shadow:0 10px 40px rgba(0,0,0,0.5);" +
      "cursor:auto;";

    var text = document.createElement("p");
    text.style.cssText = "margin:0 0 1rem 0;";
    text.innerHTML =
      "Diese Website verwendet aktuell nur technisch notwendige Funktionen, " +
      "keine Tracking-Cookies. Mehr dazu in unserer " +
      '<a href="datenschutz.html" style="color:#EDE9E0;text-decoration:underline;">Datenschutzerklärung</a>.';

    var btnRow = document.createElement("div");
    btnRow.style.cssText = "display:flex;gap:0.75rem;flex-wrap:wrap;";

    var acceptBtn = document.createElement("button");
    acceptBtn.type = "button";
    acceptBtn.textContent = "Akzeptieren";
    acceptBtn.style.cssText =
      "background:#777777;color:#060606;border:none;padding:0.6rem 1.2rem;" +
      "font-family:inherit;font-size:0.8rem;font-weight:600;text-transform:uppercase;" +
      "letter-spacing:0.05em;cursor:pointer;border-radius:2px;";
    acceptBtn.onclick = function () {
      setConsent("accepted");
    };

    var declineBtn = document.createElement("button");
    declineBtn.type = "button";
    declineBtn.textContent = "Nur notwendige";
    declineBtn.style.cssText =
      "background:transparent;color:#EDE9E0;border:1px solid rgba(255,255,255,0.16);" +
      "padding:0.6rem 1.2rem;font-family:inherit;font-size:0.8rem;text-transform:uppercase;" +
      "letter-spacing:0.05em;cursor:pointer;border-radius:2px;";
    declineBtn.onclick = function () {
      setConsent("declined");
    };

    btnRow.appendChild(acceptBtn);
    btnRow.appendChild(declineBtn);
    wrap.appendChild(text);
    wrap.appendChild(btnRow);
    document.body.appendChild(wrap);
  }

  function init() {
    var existing = localStorage.getItem(STORAGE_KEY);
    if (existing === "accepted") {
      loadAnalyticsIfConsented();
      return;
    }
    if (existing === "declined") return;
    showBanner();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
