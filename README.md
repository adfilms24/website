# A.D.Films24 — Website

Live: https://www.adfilms24.ch (Deutsch) · https://www.adfilms24.ch/en/ (English)
Hosting: Vercel (jeder Push auf `main` veröffentlicht automatisch).

## So ist die Seite aufgebaut

Die Seiten werden **nicht von Hand** geschrieben, sondern aus Textdateien gebaut:

| Was | Wo ändern |
|---|---|
| Alle Texte der Startseite (Deutsch) | `content/de.json` |
| Alle Texte der Startseite (Englisch) | `content/en.json` |
| Projekte (Titel, Beschreibung, Jahr, Video …) | `content/projects.json` |
| Impressum / Datenschutz / AGB | `content/legal/de/*.html` und `content/legal/en/*.html` |
| Aussehen | `assets/css/style.css` (Startseite, Projekte), `assets/css/legal.css` (Rechtstexte) |
| Verhalten (Menü, Formular, Video) | `assets/js/main.js` |
| Seitenrahmen | `templates/home.html`, `templates/page.html` |

Nach jeder Änderung die Seiten neu bauen:

```bash
python3 build.py
```

Danach committen und pushen — Vercel veröffentlicht automatisch. **Die erzeugten Dateien
(`index.html`, `en/`, `projekte/`, `sitemap.xml` …) nicht von Hand ändern, sie werden überschrieben.**

## Neues Projekt hinzufügen

1. Video als `assets/video/projects/<slug>.mp4` ablegen (H.264, ideal 1080p, max. ca. 8 MB) und optional ein
   Titelbild `assets/video/projects/<slug>.jpg` (16:9).
2. In `content/projects.json` den Eintrag mit demselben `slug` ausfüllen: `title`, `desc` (de + en),
   `year`, `client`, `camera` — und `"published": true` setzen.
3. `python3 build.py`, committen, pushen.

Vorbereitete Entwürfe (nicht verlinkt, nicht in Google): `commercial`, `social-media`, `real-estate`,
`drone`, `events`, `travel`. Ein neues Projekt anlegen = einen Block in `projects.json` kopieren und den `slug` ändern.

Kategorien (`category`): `commercial`, `social`, `drone`, `real-estate`, `events`, `travel`, `showreel`.

## Sonstiges

- Kein Cookie-Banner: Die Seite setzt keine Cookies (Vercel Analytics ist cookielos). Kommt ein Tool mit Cookies dazu, braucht es wieder eine Einwilligung.
- Kundenstimmen: `testimonials` in `content/de.json` / `content/en.json`.
- Leistungsliste der Startseite: `link` je Eintrag in `services` (Slug einer Leistungsseite oder `#anker`).
- Neues Showreel: unter gleichem Namen ersetzen ist ok, `build.py` hängt eine Prüfsumme an (`?v=…`).
- Kontaktformular: EmailJS (Service/Template-ID in `assets/js/main.js`).
- Sicherheits-Header und Caching: `vercel.json`.
