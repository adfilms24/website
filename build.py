#!/usr/bin/env python3
"""
Baut alle Seiten (Deutsch + Englisch) aus den Dateien in content/ und templates/.

    python3 build.py

Texte ändern      -> content/de.json bzw. content/en.json
Projekte          -> content/projects.json  (+ Video in assets/video/projects/)
Rechtstexte       -> content/legal/de/*.html bzw. content/legal/en/*.html
Die erzeugten HTML-Seiten (index.html, en/, projekte/ ...) werden mit ins Git eingecheckt.
"""
import json, os, re, sys, datetime
import html as htmllib
from urllib.parse import quote
from pathlib import Path

ROOT = Path(__file__).parent
DOMAIN = "https://www.adfilms24.ch"
LANGS = ["de", "en"]
MAIL = "info@adfilms24.ch"
# Videos (.mp4) liegen in Cloudflare R2 statt in jeder Vercel-Version; gleicher Pfad wie im Repo.
# Hochgeladen von .github/workflows/videos-r2.yml, von Vercel ausgeschlossen per .vercelignore.
MEDIA = "https://media.adfilms24.ch"

def load(p): return json.loads((ROOT / p).read_text(encoding="utf-8"))
import hashlib
_ASSET_RE = re.compile(r'(?<=["\'(=])(/assets/(?:css|js|vendor)/[\w.-]+\.(?:css|js)|/assets/video/[\w./-]+\.(?:mp4|jpg|jpeg|png|webp))(?=["\')\s>])')
def _ver(path):
    f = ROOT / path.lstrip("/")
    return hashlib.md5(f.read_bytes()).hexdigest()[:8] if f.exists() else "0"
def version_assets(html):
    """Hängt ?v=<Prüfsumme> an CSS/JS-Dateien an, damit Browser nach Änderungen sofort die neue Datei laden."""
    def sub(m):
        path = m.group(1)
        host = MEDIA if path.endswith(".mp4") else ""
        return f"{host}{path}?v={_ver(path)}"
    return _ASSET_RE.sub(sub, html)
FONTS_CSS = (ROOT / "assets/fonts/fonts.css").read_text(encoding="utf-8")
def inline_fonts(html):
    """fonts.css direkt in die Seite: spart eine blockierende Anfrage beim ersten Laden."""
    return html.replace('<link rel="stylesheet" href="/assets/fonts/fonts.css">', "<style>" + re.sub(r"\s+", " ", FONTS_CSS).strip() + "</style>")
CHANGED = set()  # Seiten, deren Inhalt sich bei diesem Build geändert hat (für lastmod in der Sitemap)
def write(rel, text):
    if rel.endswith(".html"): text = version_assets(inline_fonts(text))
    p = ROOT / rel; p.parent.mkdir(parents=True, exist_ok=True)
    if not p.exists() or p.read_text(encoding="utf-8") != text: CHANGED.add("/" + rel)
    p.write_text(text, encoding="utf-8")
def render(tpl, ctx):
    """{{key}} durch Werte ersetzen; Werte dürfen selbst {{key}} enthalten (2 Durchgänge)."""
    for _ in range(3):
        tpl = re.sub(r"\{\{(\w+)\}\}", lambda m: str(ctx[m.group(1)]) if m.group(1) in ctx else m.group(0), tpl)
    left = re.findall(r"\{\{(\w+)\}\}", tpl)
    if left: raise SystemExit(f"Unbekannte Platzhalter: {sorted(set(left))}")
    return tpl
def esc_json(o): return json.dumps(o, ensure_ascii=False).replace("</", "<\\/")

TEXT = {l: load(f"content/{l}.json") for l in LANGS}
PROJECTS = load("content/projects.json")
SERVICES = load("content/leistungen.json")

# ---------- URLs ----------
LEGAL = {  # Schlüssel -> {lang: (Pfad, Dateiname-im-content)}
    "imprint": {"de": "/impressum.html", "en": "/en/imprint.html"},
    "privacy": {"de": "/datenschutz.html", "en": "/en/privacy.html"},
    "terms":   {"de": "/agb.html",        "en": "/en/terms.html"},
}
LEGAL_SRC = {"imprint": {"de": "impressum", "en": "imprint"}, "privacy": {"de": "datenschutz", "en": "privacy"}, "terms": {"de": "agb", "en": "terms"}}
LEGAL_META = {
 "imprint": {"de": ("Impressum — A.D.Films24", "Impressum von A.D.Films24 Studio, Videoproduktion für Unternehmen in Zürich. Verantwortlich: Abdi Dhiblawe."),
             "en": ("Imprint — A.D.Films24", "Imprint of A.D.Films24 Studio, video production for businesses in Zurich. Responsible: Abdi Dhiblawe.")},
 "privacy": {"de": ("Datenschutzerklärung — A.D.Films24", "Datenschutzerklärung von A.D.Films24 — Informationen zur Bearbeitung von Personendaten nach Schweizer DSG und DSGVO."),
             "en": ("Privacy policy — A.D.Films24", "Privacy policy of A.D.Films24 — information on the processing of personal data under the Swiss FADP and GDPR.")},
 "terms":   {"de": ("AGB — A.D.Films24", "Allgemeine Geschäftsbedingungen (AGB) von A.D.Films24."),
             "en": ("Terms — A.D.Films24", "General terms and conditions of A.D.Films24 (convenience translation).")},
}
def home_url(l): return "/" if l == "de" else "/en/"
def project_url(l, slug): return f"/projekte/{slug}.html" if l == "de" else f"/en/projects/{slug}.html"
def service_url(l, s): return f"/leistungen/{s['slug']['de']}.html" if l == "de" else f"/en/services/{s['slug']['en']}.html"
def other(l): return "en" if l == "de" else "de"
def hreflang(urls):
    return "\n".join([f'<link rel="alternate" hreflang="{l}" href="{DOMAIN}{u}">' for l, u in urls.items()] +
                     [f'<link rel="alternate" hreflang="x-default" href="{DOMAIN}{urls["de"]}">'])
def common_ctx(l, urls):
    t = dict(TEXT[l]); o = other(l)
    t.update(lang=l, other_lang=o, canonical=DOMAIN + urls[l], hreflang=hreflang(urls),
             lang_switch_url=urls[o], og_locale=t.get("pj_og_locale", "de_CH"),
             imprint_url=LEGAL["imprint"][l], privacy_url=LEGAL["privacy"][l], terms_url=LEGAL["terms"][l],
             home_url=home_url(l))
    return t

# ---------- Projekte ----------
def has_video(p):
    if p.get("video"): return p["video"]
    f = f"assets/video/projects/{p['slug']}.mp4"
    return "/" + f if (ROOT / f).exists() else None
def preview_of(p):
    """Kurzer stummer Clip (4 s, klein) für die Vorschau beim Hovern im Portfolio, falls vorhanden."""
    f = f"assets/video/previews/{p['slug']}.mp4"
    return "/" + f if (ROOT / f).exists() else None
def webp_of(path):
    """Gleiches Bild als WebP, falls vorhanden (kleiner); sonst das Original."""
    if path and path.endswith(".jpg") and (ROOT / (path[:-4] + ".webp").lstrip("/")).exists(): return path[:-4] + ".webp"
    return path
def poster_of(p):
    if p.get("poster"): return p["poster"]
    f = f"assets/video/projects/{p['slug']}.jpg"
    return "/" + f if (ROOT / f).exists() else None
def tag_of(p, l):
    cat = TEXT[l]["categories"].get(p["category"], p["category"])
    return f'{cat} · {p["year"]}' if p.get("year") else cat

def ticker(t):
    row = "\n".join(f'    <span class="tick"><span class="hi">{w}</span><span class="tick-sep">✦</span></span>' for w in t["ticker"])
    return f'<div class="ticker-track">\n{row}\n    <!-- duplicate -->\n{row}\n  </div>'
def marquee(t):
    row = "\n".join(f'    <span class="dm-item">{a} <span class="o">{b}</span></span>' for a, b in t["marquee"])
    return f'<div class="divider-marquee" aria-hidden="true">\n{row}\n{row}\n  </div>'
def gear(t):
    # Optional dritter Eintrag: Nutzen in einem Satz (was der Kunde davon hat)
    return "\n".join(f'            <div class="gear-row"><span class="gear-name">{g[0]}' + (f'<span class="gear-benefit">{g[2]}</span>' if len(g) > 2 else "") + f'</span><span class="gear-type">{g[1]}</span></div>' for g in t["gear"])
ARROW = '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>'
def services(l, t):
    """Leistungsliste der Startseite; "link" in content/<lang>.json = Slug einer Leistungsseite oder ein #Anker."""
    out = []
    by_slug = {sv["slug"]["de"]: sv for sv in SERVICES}
    for s in t["services"]:
        link = s.get("link", "#contact")
        href = link if link.startswith("#") else service_url(l, by_slug[link])
        tags = "\n".join(f'          <span class="srv-tag">{x}</span>' for x in s["tags"])
        out.append(f'''      <a class="srv-item" href="{href}">
        <div class="srv-num">{s["num"]}</div>
        <div class="srv-name">{s["name"]}<em>{s["sub"]}</em></div>
        <div class="srv-tags">
{tags}
        </div>
        <div class="srv-arrow">
          {ARROW}
        </div>
      </a>''')
    return "\n\n" + "\n\n".join(out) + "\n"
def service_links(l, t):
    links = " ".join(f'<a href="{service_url(l, s)}">{s["nav"][l]}</a>' for s in SERVICES)
    return f'<p class="srv-more" data-sr="u"><span>{t["srv_more_label"]}</span> {links}</p>'
def opts(items):
    return "\n".join(f'            <option>{x}</option>' for x in items)
def radios(name, items, required=False):
    """Auswahl-Chips für das mehrstufige Anfrageformular (ein Wert pro Gruppe)."""
    req = " required" if required else ""
    return "\n".join(f'            <label class="f-chip"><input type="radio" name="{name}" value="{htmllib.escape(x, quote=True)}"{req}><span>{x}</span></label>' for x in items)
def testimonials(t):
    note = f'\n        <p class="test-note">{t["testimonials_note"]}</p>' if t.get("testimonials_note") else ""
    return "\n".join(f'''        <div class="test-card" data-sr="r" data-d="{i + 1}">
          <span class="test-q">&ldquo;</span>
          <p class="test-body">{q}</p>
          <div class="test-foot"><div>
            <div class="test-author-name">{name}</div>
            <div class="test-author-role">{role}</div>
          </div></div>
        </div>''' for i, (q, name, role) in enumerate(t["testimonials"])) + note
def faq_items(t):
    return "\n".join(f'''      <details class="faq-item">
        <summary>{q}</summary>
        <p>{a}</p>
      </details>''' for q, a in t["faq"])
def process_steps(t):
    return "".join(f'<li><span class="lp-step-n">0{i+1}</span><strong>{a}</strong><span>{b}</span></li>' for i, (a, b) in enumerate(t["lp_steps"]))
PROC_ICONS = {
    "talk": "M4 5h11v8H8l-4 3zM9 15v2h7l4 3v-9h-3",
    "plan": "M4 6h16v14H4zM4 10h16M8 3v4M16 3v4M9 15l2 2 4-4",
    "cam": "M3 8h11v9H3zM14 11l6-3v9l-6-3M6 5h4",
    "monitor": "M7 3h10v18H7zM11 18h2M10.5 8.5v5l4-2.5z",
    "grade": "M4 7h10M18 7h2M4 17h4M12 17h8M14 7a2 2 0 1 0 4 0a2 2 0 1 0-4 0M8 17a2 2 0 1 0 4 0a2 2 0 1 0-4 0",
}
def problems(l, t):
    """Problem-Block der Startseite: Business-Problem, Lösung, Link auf die passende Leistungsseite."""
    by_slug = {sv["slug"]["de"]: sv for sv in SERVICES}
    return "\n".join(f'''      <a class="prob-item" href="{service_url(l, by_slug[p[3]])}" data-sr="u" data-d="{i + 1}">
        <h3 class="prob-name">{p[0]}</h3>
        <p class="prob-text">{p[1]}</p>
        <span class="prob-link">{p[2]} {ARROW}</span>
      </a>''' for i, p in enumerate(t["problems"]))

def proc_steps_html(t):
    n = len(t["proc_steps"])
    return "".join(
        f'<li class="proc-step" data-sr="u" data-d="{min(i + 1, 5)}"><span class="proc-ico" aria-hidden="true">'
        f'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="{PROC_ICONS[ic]}"/></svg></span>'
        f'<span class="proc-n">{i + 1:02d} <span>/ {n:02d}</span></span><strong>{a}</strong><span class="proc-t">{b}</span></li>'
        for i, (ic, a, b) in enumerate(t["proc_steps"]))
def look_tabs_html(t):
    return "".join(f'<button type="button" class="look-tab{" on" if i == 0 else ""}" data-look="{k}" aria-pressed="{"true" if i == 0 else "false"}">{lab}</button>'
                   for i, (k, lab) in enumerate(t["look_tabs"]))
def video_id(l, p): return DOMAIN + project_url(l, p["slug"]) + "#video"
def video_ld(l, p):
    """schema.org/VideoObject für ein Projektvideo. Optional in projects.json:
    "video_name"/"video_desc" {de,en}: eigener Videotitel/-text für Google & KI-Suche,
    "chapters": [[Sekunde, {"de": "…", "en": "…"}], …]: Key Moments (nur echte Zeitmarken eintragen)."""
    vid, poster = has_video(p), poster_of(p)
    page = DOMAIN + project_url(l, p["slug"])
    d = {"@context": "https://schema.org", "@type": "VideoObject", "@id": video_id(l, p),
         "name": p.get("video_name", {}).get(l) or p.get("seo", {}).get(l) or p["title"][l],
         "description": p.get("video_desc", {}).get(l) or p["desc"][l],
         "thumbnailUrl": (DOMAIN + poster) if poster else DOMAIN + "/og-image.png",
         "uploadDate": p.get("uploadDate", "2026-01-01"), **({"duration": p["duration"]} if p.get("duration") else {}),
         "contentUrl": MEDIA + vid, "url": page, "inLanguage": "de-CH" if l == "de" else "en",
         "creator": {"@id": DOMAIN + "/#business"}, "publisher": {"@id": DOMAIN + "/#business"}}
    ch = p.get("chapters") or []
    if ch:
        ends = [s for s, _ in ch[1:]] + [video_secs(p.get("duration")) or ch[-1][0] + 1]
        d["hasPart"] = [{"@type": "Clip", "name": n[l], "startOffset": s, "endOffset": e, "url": f"{page}#t={s}"}
                        for (s, n), e in zip(ch, ends)]
    return d
def video_secs(dur):
    m = re.fullmatch(r"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?", dur or "")
    return (int(m[1] or 0) * 3600 + int(m[2] or 0) * 60 + int(m[3] or 0)) if m else None
SHOWCASE = ["showreel-2026", "loco-birria"]  # Hauptvideos, mit dem Unternehmen verknüpft (subjectOf)
def business_ld(l, t):
    org = {"@context": "https://schema.org", "@type": "ProfessionalService", "@id": DOMAIN + "/#business",
           "name": "A.D.Films24", "alternateName": "A.D.Films24 Studio", "slogan": "Capture More",
           "description": t["ld_desc"], "url": DOMAIN + home_url(l), "email": MAIL, "telephone": "+41767649300",
           "logo": DOMAIN + "/icon-512.png", "image": DOMAIN + "/og-image.png",
           "address": {"@type": "PostalAddress", "addressLocality": "Zürich", "addressCountry": "CH"},
           "areaServed": [{"@type": "City", "name": "Zürich"}, {"@type": "Country", "name": "Schweiz"}],
           "founder": {"@type": "Person", "@id": DOMAIN + "/#abdi", "name": "Abdi Dhiblawe", "jobTitle": t["about_tag"].split("·")[-1].strip(),
                       "worksFor": {"@id": DOMAIN + "/#business"}, "knowsAbout": t["ld_knows"]},
           "knowsAbout": t["ld_knows"],
           "subjectOf": [{"@id": video_id(l, p)} for p in PROJECTS if p["slug"] in SHOWCASE and p.get("published") and has_video(p)],
           "makesOffer": [{"@type": "Offer", "itemOffered": {"@type": "Service", "name": re.sub("&amp;", "&", sv["h1"][l]), "url": DOMAIN + service_url(l, sv)}} for sv in SERVICES],
           "sameAs": ["https://instagram.com/a.d.films24", "https://www.youtube.com/@adfilms24", t["google_url"]]}
    site = {"@context": "https://schema.org", "@type": "WebSite", "@id": DOMAIN + "/#website", "name": "A.D.Films24",
            "url": DOMAIN + "/", "inLanguage": ["de-CH", "en"], "publisher": {"@id": DOMAIN + "/#business"}}
    faq = {"@context": "https://schema.org", "@type": "FAQPage",
           "mainEntity": [{"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in t["faq"]]}
    reel = [video_ld(l, p) for p in PROJECTS if p["slug"] == "showreel-2026" and p.get("published") and has_video(p)]
    return "\n".join(f'<script type="application/ld+json">{esc_json(x)}</script>' for x in (org, site, faq, *reel))
SIZES = ["xl", "tall", "wide", "wide", "wide", "wide"]  # je zwei Kacheln füllen eine Reihe (6+4 bzw. 5+5 von 10 Spalten)
BGS = ["bg-a", "bg-b", "bg-c", "bg-d", "bg-e", "bg-f"]
def projects_grid(l, t):
    pub = [p for p in PROJECTS if p.get("published")]
    cells = []
    for i, p in enumerate(pub):
        poster = poster_of(p); vid = has_video(p)
        title = p["title"][l]
        # Bild erst laden, wenn die Kachel in die Nähe kommt (main.js, lazyBackgrounds): spart auf dem Handy rund 580 KB beim ersten Laden
        style = f' data-bg="{webp_of(poster)}"' if poster else ""
        bg = "pf-cell-bg has-img" if poster else f"pf-cell-bg {BGS[i % 6]}"
        glyph = "" if poster else f'<span class="pf-glyph">{title[:1]}</span>'
        play = '\n        <div class="pf-play"><svg width="22" height="24" viewBox="0 0 16 18" fill="none"><path d="M2 2L14 9L2 16V2Z" fill="#EDE9E0"/></svg></div>' if vid else ""
        size = "xl" if len(pub) == 1 else ("full" if i == len(pub) - 1 and len(pub) % 2 else SIZES[i % 6])
        feat = " featured" if vid and poster else ""
        prev = preview_of(p) if vid else None
        prev_attr = f' data-preview="{prev}"' if prev else ""
        cells.append(f'''      <a class="pf-cell{feat}" href="{project_url(l, p["slug"])}" data-size="{size}" data-cat="{p["category"]}"{prev_attr} aria-label="{title} — {tag_of(p, l)}">
        <div class="{bg}"{style}>{glyph}</div>{play}
        <div class="pf-overlay">
          <div class="pf-tag">{tag_of(p, l)}</div>
          <div class="pf-title">{title}</div>
        </div>
      </a>''')
    single = " single" if len(pub) == 1 else ""
    filters = ""
    cats = []
    for p in pub:
        if p["category"] not in cats: cats.append(p["category"])
    if len(pub) >= 3 and len(cats) >= 2:   # Filter erst sinnvoll, wenn mehrere Projekte/Kategorien da sind
        btns = f'<button type="button" class="pf-btn active" data-f="all">{t["pf_all"]}</button>' + "".join(
            f'<button type="button" class="pf-btn" data-f="{c}">{t["categories"].get(c, c)}</button>' for c in cats)
        filters = f'    <div class="pf-filters" role="group" aria-label="{t["pf_filter_aria"]}" data-sr="u" style="margin-bottom:1.5rem">{btns}</div>\n'
    return (filters + f'    <div class="pf-mosaic{single}" data-sr="u" data-d="2">\n' + "\n".join(cells) + "\n    </div>\n"
            + (f'    <p class="soon-note" style="margin-top:2px;" data-sr="u">{t["portfolio_soon"]}</p>' if t["portfolio_soon"] else ""))

# ---------- Seiten ----------
def build_home(l):
    urls = {x: home_url(x) for x in LANGS}
    t = common_ctx(l, urls)
    t.update(ticker=ticker(t), marquee=marquee(t), gear=gear(t), services=services(l, t), problems_html=problems(l, t), testimonials=testimonials(t), service_links=service_links(l, t), projects_grid=projects_grid(l, t),
             business_ld=business_ld(l, t), process_steps=process_steps(t), proc_steps_html=proc_steps_html(t), look_tabs_html=look_tabs_html(t), faq_items=faq_items(t),
             project_type_radios=radios("projekttyp", t["project_types"], required=True), budget_radios=radios("budget", t["budget_opts"]),
             timeframe_radios=radios("zeitrahmen", t["timeframe_opts"]), industry_radios=radios("branche", t["industry_opts"]), source_opts_html=opts(t["source_opts"]),
             footer_service_links="\n".join(f'      <li><a href="{service_url(l, sv)}">{sv["nav"][l]}</a></li>' for sv in SERVICES),
             year=datetime.date.today().year)
    keys = ["menu_open", "menu_close", "showreel_title", "showreel_desc", "showreel_client", "showreel_camera", "showreel_year",
            "form_wait", "form_sending", "form_sending_status", "form_sent_btn", "form_ok", "form_fail", "lbl_budget", "lbl_date", "lbl_source", "lbl_phone",
            "lbl_timeframe", "lbl_industry", "lbl_company", "step_of"]
    # Showreel-Pfade laufen durch version_assets (?v=…), damit ein neues Video trotz Jahres-Cache sofort ankommt
    t["i18n_json"] = esc_json({**{k: TEXT[l][k] for k in keys}, "mail": MAIL, "lang": l,
                               "showreel_src": "/assets/video/showreel.mp4", "showreel_poster": "/assets/video/showreel-poster.webp"})
    html = render((ROOT / "templates/home.html").read_text(encoding="utf-8"), t)
    write("index.html" if l == "de" else "en/index.html", html)

def og_for(slug):
    return f"{DOMAIN}/og/{slug}.jpg" if (ROOT / f"og/{slug}.jpg").exists() else f"{DOMAIN}/og-image.png"
def page_shell(l, urls, title, desc, body, robots="index, follow", extra_head="", body_class="", css="legal.css", og_image=None):
    t = common_ctx(l, urls)
    if css == "style.css":  # Projekt- und Leistungsseiten: Schriften vorladen, damit sich nichts verschiebt
        extra_head = "".join(f'<link rel="preload" href="/assets/fonts/{f}.woff2" as="font" type="font/woff2" crossorigin>' for f in (
            "JTUSjIg69CK48gW7PXoo9WlhyyTh89Y", "jizHRFtNs2ka5fXjeivQ4LroWlx-6zAjjH7Motmp5g", "jizBRFtNs2ka5fXjeivQ4LroWlx-6zUTjnTLgNs")) + extra_head
    t.update(title=title, desc=desc, body=body, robots=robots, extra_head=extra_head, body_class=body_class, css=css,
             og_image=og_image or f"{DOMAIN}/og-image.png",
             legal_back=TEXT[l]["legal_back"])
    return render((ROOT / "templates/page.html").read_text(encoding="utf-8"), t)

def footer_links(l):
    svc = "".join(f'\n    <a href="{service_url(l, sv)}">{sv["nav"][l]}</a>' for sv in SERVICES)
    return (f'<a href="{home_url(l)}">{TEXT[l]["legal_home"]}</a>{svc}\n    <a href="{LEGAL["imprint"][l]}">{TEXT[l]["foot_imprint"]}</a>\n'
            f'    <a href="{LEGAL["privacy"][l]}">{TEXT[l]["foot_privacy"]}</a>\n    <a href="{LEGAL["terms"][l]}">{TEXT[l]["foot_terms"]}</a>')
def breadcrumb_ld(l, items):
    return '<script type="application/ld+json">' + esc_json({"@context": "https://schema.org", "@type": "BreadcrumbList",
        "itemListElement": [{"@type": "ListItem", "position": i + 1, "name": n, "item": DOMAIN + u} for i, (n, u) in enumerate(items)]}) + '</script>'

WA_NUMBER = "41767649300"
def contact_href(l, sv=None):
    """Link zum Formular. Mit ?typ=N ist die Projektart schon gewählt und das Formular startet bei Schritt 2."""
    return home_url(l) + (f'?typ={sv["form_type"]}' if sv and "form_type" in sv else "") + "#contact"
def cta_buttons(l, t, sv=None):
    """Anfrage-Button + WhatsApp mit vorausgefülltem Text (Leistung im Text, damit klar ist, worum es geht)."""
    topic = sv["nav"][l] if sv else t["pj_cta"]
    wa = f'https://wa.me/{WA_NUMBER}?text=' + quote(t["wa_text"].replace("{x}", topic))
    return (f'<a href="{contact_href(l, sv)}" class="cta-primary">{ARROW} {t["pj_cta"]}</a>'
            f'<a href="{wa}" class="cta-ghost cta-wa" target="_blank" rel="noopener">{t["wa_cta"]}</a>')
def faq_ld(pairs):
    return '<script type="application/ld+json">' + esc_json({"@context": "https://schema.org", "@type": "FAQPage", "mainEntity": [
        {"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in pairs]}) + '</script>'

def legal_wrap(l, urls, body):
    t = TEXT[l]
    return f'''<div class="wrap">
  <header class="page-head">
    <a href="{home_url(l)}" class="logo" aria-label="A.D.Films24">www.adfilms24.ch<span>.</span></a>
    <div class="head-links">
      <a href="{urls[other(l)]}" class="back-link" hreflang="{other(l)}" lang="{other(l)}" aria-label="{t["lang_switch_aria"]}">{t["lang_switch_label"]}</a>
      <a href="{home_url(l)}" class="back-link">{t["legal_back"]}</a>
    </div>
  </header>
{body}
</div>'''

def build_legal():
    for key in LEGAL:
        urls = {l: LEGAL[key][l] for l in LANGS}
        for l in LANGS:
            body = (ROOT / f"content/legal/{l}/{LEGAL_SRC[key][l]}.html").read_text(encoding="utf-8")
            title, desc = LEGAL_META[key][l]
            body += f'\n  <footer class="page-foot">\n    {footer_links(l)}\n  </footer>'
            write(urls[l].lstrip("/"), page_shell(l, urls, title, desc, legal_wrap(l, urls, body)))

CAT_SERVICE = {"commercial": "imagefilm-zuerich", "showreel": "imagefilm-zuerich", "social": "social-media-content-zuerich", "events": "event-video-zuerich", "food": "restaurant-video-zuerich", "fitness": "imagefilm-zuerich", "automotive": "social-media-content-zuerich"}
def build_projects():
    for p in PROJECTS:
        urls = {l: project_url(l, p["slug"]) for l in LANGS}
        for l in LANGS:
            t = TEXT[l]; vid = has_video(p); poster = poster_of(p)
            title = p["title"][l]; draft = not p.get("published")
            seo = p.get("seo", {}).get(l) or title  # Google-Titel mit Leistung und Ort, z.B. «Restaurant-Video Zürich: Loco Birriá»
            cat = t["categories"].get(p["category"], p["category"])
            if vid:
                pa = f' poster="{webp_of(poster)}"' if poster else ""
                video = f'<video controls playsinline preload="metadata"{pa}><source src="{vid}" type="video/mp4"></video>'
            else:
                video = f'<div class="pj-soon"><span>▶</span><p>{t["pj_soon"]}</p></div>'
            rows = []
            for lab, val in [("pj_category", cat), ("pj_client", p.get("client")), ("pj_year", p.get("year")), ("pj_camera", p.get("camera"))]:
                if val: rows.append(f'<div><dt>{t[lab]}</dt><dd>{val}</dd></div>')
            ld = ""
            if vid and not draft:
                ld = '<script type="application/ld+json">' + esc_json(video_ld(l, p)) + '</script>'
                # og:video: Facebook/LinkedIn können das Video direkt im Feed zeigen; WhatsApp & iMessage nutzen weiter og:image
                ld += (f'<meta property="og:video" content="{MEDIA + vid}"><meta property="og:video:secure_url" content="{MEDIA + vid}">'
                       f'<meta property="og:video:type" content="video/mp4">')
            draft_note = f'<p class="pj-draft">{t["pj_draft"]}</p>' if draft else ""
            # Optional in projects.json: "story": {"de": ["Ausgangslage …", "Umsetzung …", "Ergebnis …"], "en": [...]}
            story = "".join(f'<h2 class="pj-story-h">{h}</h2><p class="pj-story">{txt}</p>' for h, txt in zip(t["pj_story"], p.get("story", {}).get(l, [])))
            sv = next((x for x in SERVICES if x["slug"]["de"] == CAT_SERVICE.get(p["category"])), None)
            related = f'<p class="srv-more lp-more"><span>{t["pj_service"]}</span> <a href="{service_url(l, sv)}">{sv["nav"][l]}</a></p>' if sv else ""
            if not draft:
                ld += breadcrumb_ld(l, [(t["legal_home"], home_url(l)), (seo, urls[l])])
            body = f'''<nav id="nav" class="pinned pj-nav">
    <a href="{home_url(l)}" class="nav-logo" aria-label="A.D. Films24"><img src="/logo.svg" alt="A.D.Films24 – Capture More" class="nav-logo-img" width="302" height="52"></a>
    <div class="nav-right">
      <a href="{home_url(l)}#portfolio" class="nav-lang pj-backlink">{t["pj_back"]}</a>
      <a href="{urls[other(l)]}" class="nav-lang" hreflang="{other(l)}" lang="{other(l)}" aria-label="{t["lang_switch_aria"]}">{t["lang_switch_label"]}</a>
    </div>
  </nav>
  <main id="main" tabindex="-1" class="pj">
    {draft_note}
    <p class="s-meta">{cat}</p>
    <h1 class="h-display pj-title">{title}</h1>
    <div class="pj-video{' pj-video--v' if p.get('format') == 'vertical' else ''}">{video}</div>
    <div class="pj-body">
      <div>
        <p class="pj-desc">{p["desc"][l]}</p>
        {story}
      </div>
      <dl class="pj-meta">{''.join(rows)}</dl>
    </div>
    <div class="pj-cta">
      <h2>{t["pj_cta_h"]}</h2>
      <div class="cta-pair">{cta_buttons(l, t, sv)}</div>
    </div>
    {related}
    <footer class="page-foot pj-foot">
      {footer_links(l)}
    </footer>
  </main>'''
            html = page_shell(l, urls, f'{seo} — A.D.Films24', p.get("meta", p["desc"])[l], body,
                              robots="noindex, nofollow" if draft else "index, follow", extra_head=ld, body_class="page-project", css="style.css", og_image=og_for(p["slug"]))
            write(urls[l].lstrip("/"), html)

def build_services():
    by_slug = {p["slug"]: p for p in PROJECTS}
    for s in SERVICES:
        urls = {l: service_url(l, s) for l in LANGS}
        for l in LANGS:
            t = TEXT[l]; p = by_slug.get(s["project"])
            vid = has_video(p) if p and p.get("published") else None
            video = ""
            if vid:
                poster = poster_of(p); pa = f' poster="{webp_of(poster)}"' if poster else ""
                video = (f'<p class="s-meta lp-label">{t["lp_example"]}: <a href="{project_url(l, p["slug"])}">{p["title"][l]}</a></p>\n'
                         f'    <div class="pj-video{' pj-video--v' if p.get('format') == 'vertical' else ''}"><video controls playsinline preload="metadata"{pa}><source src="{vid}" type="video/mp4"></video></div>')
            inc = "".join(f"<li>{x}</li>" for x in s["includes"][l])
            who = "".join(f"<li>{x}</li>" for x in s["for"][l])
            steps = "".join(f'<li><span class="lp-step-n">0{i+1}</span><strong>{a}</strong><span>{b}</span></li>' for i, (a, b) in enumerate(s.get("steps", {}).get(l, t["lp_steps"])))
            pairs = s.get("faq", {}).get(l, [])
            faq = (f'<h2 class="lp-h">{t["lp_faq"]}</h2>\n    <div class="faq-list lp-faq">' + "".join(
                f'<details class="faq-item"><summary>{q}</summary><p>{a}</p></details>' for q, a in pairs) + '</div>') if pairs else ""
            more = " ".join(f'<a href="{service_url(l, o)}">{o["nav"][l]}</a>' for o in SERVICES if o is not s)
            ld = '<script type="application/ld+json">' + esc_json({
                "@context": "https://schema.org", "@type": "Service", "name": re.sub(r"&amp;", "&", s["h1"][l]),
                "description": s["meta"][l], "areaServed": {"@type": "City", "name": "Zürich" if l == "de" else "Zurich"},
                "provider": {"@type": "Organization", "name": "A.D.Films24", "url": DOMAIN + "/"}, "url": DOMAIN + urls[l]}) + '</script>'
            body = f'''<nav id="nav" class="pinned pj-nav">
    <a href="{home_url(l)}" class="nav-logo" aria-label="A.D. Films24"><img src="/logo.svg" alt="A.D.Films24 – Capture More" class="nav-logo-img" width="302" height="52"></a>
    <div class="nav-right">
      <a href="{home_url(l)}#services" class="nav-lang pj-backlink">← {t["n_services"]}</a>
      <a href="{urls[other(l)]}" class="nav-lang" hreflang="{other(l)}" lang="{other(l)}" aria-label="{t["lang_switch_aria"]}">{t["lang_switch_label"]}</a>
    </div>
  </nav>
  <main id="main" tabindex="-1" class="pj lp">
    <p class="s-meta">{t["lp_meta"]}</p>
    <h1 class="h-display pj-title">{s["h1"][l]}</h1>
    <p class="lp-intro">{s["intro"][l]}</p>
    <div class="cta-pair lp-cta-top">{cta_buttons(l, t, s)}<span class="lp-reply">{t["lp_reply"]}</span></div>
    <div class="lp-cols">
      <div><h2 class="lp-h">{t["lp_includes"]}</h2><ul class="lp-list">{inc}</ul></div>
      <div><h2 class="lp-h">{t["lp_for"]}</h2><ul class="lp-list">{who}</ul></div>
    </div>
    {video}
    <h2 class="lp-h">{t["lp_process"]}</h2>
    <ol class="lp-steps">{steps}</ol>
    <p class="lp-promise">{s.get("promise", {}).get(l, t["lp_promise"])}</p>
    {faq}
    <div class="pj-cta">
      <h2>{t["lp_cta_h"]}</h2>
      <div class="cta-pair">{cta_buttons(l, t, s)}</div>
    </div>
    <p class="srv-more lp-more"><span>{t["lp_more"]}</span> {more}</p>
    <footer class="page-foot pj-foot">
      {footer_links(l)}
    </footer>
  </main>'''
            if pairs: ld += faq_ld(pairs)
            ld += breadcrumb_ld(l, [(t["legal_home"], home_url(l)), (t["n_services"], home_url(l) + "#services"), (re.sub("&amp;", "&", s["h1"][l]), urls[l])])
            html = page_shell(l, urls, s["title"][l], s["meta"][l], body, extra_head=ld, body_class="page-project", css="style.css", og_image=og_for(s["slug"]["de"]))
            write(urls[l].lstrip("/"), html)

def build_404():
    body = '''  <h1>404</h1>
  <p class="meta-line">Seite nicht gefunden · Page not found</p>
  <p>Diese Seite gibt es nicht (mehr). Zurück zur <a href="/">Startseite</a> oder zum <a href="/#contact">Kontaktformular</a>.</p>
  <p>This page does not exist (any more). Back to the <a href="/en/">home page</a> or the <a href="/en/#contact">contact form</a>.</p>
  <footer class="page-foot">
    <a href="/">Startseite</a>
    <a href="/en/">Home (EN)</a>
    <a href="/impressum.html">Impressum</a>
    <a href="/datenschutz.html">Datenschutz</a>
  </footer>'''
    urls = {"de": "/404.html", "en": "/404.html"}
    html = page_shell("de", urls, "Seite nicht gefunden — A.D.Films24", "Diese Seite existiert nicht.", '<div class="wrap">\n' + body + "\n</div>", robots="noindex")
    html = re.sub(r'<link rel="canonical"[^>]*>\n?', "", html); html = re.sub(r'<link rel="alternate"[^>]*>\n?', "", html)
    write("404.html", html)

def build_sitemap():
    # lastmod nur erneuern, wenn sich die Seite geändert hat. So bleibt der Build an jedem Tag gleich (CI) und Google sieht echte Änderungsdaten.
    # sitemap.xml ist ein Sitemap-Index (in der Search Console registriert) -> sitemap-pages.xml + video-sitemap.xml
    sm = ROOT / "sitemap-pages.xml"
    if not sm.exists(): sm = ROOT / "sitemap.xml"  # einmalig: Daten aus der alten Seiten-Sitemap übernehmen
    old = dict(re.findall(r"<loc>" + re.escape(DOMAIN) + r"(.*?)</loc>.*?<lastmod>(.*?)</lastmod>", sm.read_text(encoding="utf-8"), re.S)) if sm.exists() else {}
    today = datetime.date.today().isoformat()
    def lastmod(u):
        f = u + "index.html" if u.endswith("/") else u
        return today if f in CHANGED or u not in old else old[u]
    def entry(urls, prio, freq):
        alts = "".join(f'\n    <xhtml:link rel="alternate" hreflang="{l}" href="{DOMAIN}{u}"/>' for l, u in urls.items())
        alts += f'\n    <xhtml:link rel="alternate" hreflang="x-default" href="{DOMAIN}{urls["de"]}"/>'
        return "".join(f'  <url>\n    <loc>{DOMAIN}{urls[l]}</loc>{alts}\n    <lastmod>{lastmod(urls[l])}</lastmod>\n    <changefreq>{freq}</changefreq>\n    <priority>{prio}</priority>\n  </url>\n' for l in LANGS)
    out = entry({l: home_url(l) for l in LANGS}, "1.0", "monthly")
    for p in PROJECTS:
        if p.get("published"): out += entry({l: project_url(l, p["slug"]) for l in LANGS}, "0.8", "monthly")
    for sv in SERVICES: out += entry({l: service_url(l, sv) for l in LANGS}, "0.9", "monthly")
    for k in LEGAL: out += entry({l: LEGAL[k][l] for l in LANGS}, "0.2", "yearly")
    write("sitemap-pages.xml", '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n' + out + '</urlset>\n')
    newest = max(re.findall(r"<lastmod>(.*?)</lastmod>", out))
    write("sitemap.xml", '<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
          f'  <sitemap>\n    <loc>{DOMAIN}/sitemap-pages.xml</loc>\n    <lastmod>{newest}</lastmod>\n  </sitemap>\n'
          f'  <sitemap>\n    <loc>{DOMAIN}/video-sitemap.xml</loc>\n  </sitemap>\n</sitemapindex>\n')

def build_video_sitemap():
    """Eigene Video-Sitemap für Google: nur die Projektseiten (dort ist das Video der Hauptinhalt = «Watch Page»)."""
    def x(v): return htmllib.escape(str(v), quote=True)
    def secs(d):
        m = re.fullmatch(r"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?", d or "")
        return (int(m[1] or 0) * 3600 + int(m[2] or 0) * 60 + int(m[3] or 0)) if m else None
    out = ""
    for p in PROJECTS:
        vid = has_video(p)
        if not (p.get("published") and vid): continue
        poster = poster_of(p)
        for l in LANGS:
            sec = secs(p.get("duration"))
            out += (f'  <url>\n    <loc>{DOMAIN}{project_url(l, p["slug"])}</loc>\n    <video:video>\n'
                    f'      <video:thumbnail_loc>{x(DOMAIN + poster if poster else DOMAIN + "/og-image.png")}</video:thumbnail_loc>\n'
                    f'      <video:title>{x(p.get("video_name", {}).get(l) or p.get("seo", {}).get(l) or p["title"][l])}</video:title>\n'
                    f'      <video:description>{x(p.get("video_desc", {}).get(l) or p["desc"][l])}</video:description>\n'
                    f'      <video:content_loc>{x(MEDIA + vid)}</video:content_loc>\n'
                    + (f'      <video:duration>{sec}</video:duration>\n' if sec else "")
                    + (f'      <video:publication_date>{p["uploadDate"]}</video:publication_date>\n' if p.get("uploadDate") else "")
                    + f'      <video:family_friendly>yes</video:family_friendly>\n'
                    + f'      <video:uploader info="{DOMAIN}/">A.D.Films24 Studio</video:uploader>\n    </video:video>\n  </url>\n')
    write("video-sitemap.xml", '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">\n' + out + '</urlset>\n')

if __name__ == "__main__":
    for l in LANGS: build_home(l)
    build_legal(); build_projects(); build_services(); build_404(); build_sitemap(); build_video_sitemap()
    n_pub = sum(1 for p in PROJECTS if p.get("published"))
    print(f"OK: 2 Startseiten, {n_pub} veröffentlichte + {len(PROJECTS)-n_pub} Entwurf-Projekte (je DE/EN), {len(SERVICES)} Leistungsseiten, Rechtstexte, 404, Sitemap")
