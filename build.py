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
from pathlib import Path

ROOT = Path(__file__).parent
DOMAIN = "https://www.adfilms24.ch"
LANGS = ["de", "en"]
MAIL = "info@adfilms24.ch"

def load(p): return json.loads((ROOT / p).read_text(encoding="utf-8"))
import hashlib
_ASSET_RE = re.compile(r'(?<=["\'(=])(/assets/(?:css|js|vendor)/[\w.-]+\.(?:css|js)|/assets/video/[\w./-]+\.(?:mp4|jpg|jpeg|png|webp)|/cookie-consent\.js)(?=["\')\s>])')
def _ver(path):
    f = ROOT / path.lstrip("/")
    return hashlib.md5(f.read_bytes()).hexdigest()[:8] if f.exists() else "0"
def version_assets(html):
    """Hängt ?v=<Prüfsumme> an CSS/JS-Dateien an, damit Browser nach Änderungen sofort die neue Datei laden."""
    return _ASSET_RE.sub(lambda m: f"{m.group(1)}?v={_ver(m.group(1))}", html)
def write(rel, text):
    if rel.endswith(".html"): text = version_assets(text)
    p = ROOT / rel; p.parent.mkdir(parents=True, exist_ok=True); p.write_text(text, encoding="utf-8")
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
 "imprint": {"de": ("Impressum — A.D.Films24", "Impressum von A.D.Films24 — Abdi Dhiblawe, Cinematographer & Content Creator, Schweiz."),
             "en": ("Imprint — A.D.Films24", "Imprint of A.D.Films24 — Abdi Dhiblawe, cinematographer & content creator, Switzerland.")},
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
    return f'<div class="divider-marquee">\n{row}\n{row}\n  </div>'
def gear(t):
    return "\n".join(f'            <div class="gear-row"><span class="gear-name">{n}</span><span class="gear-type">{ty}</span></div>' for n, ty in t["gear"])
ARROW = '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>'
def services(t):
    out = []
    for s in t["services"]:
        tags = "\n".join(f'          <span class="srv-tag">{x}</span>' for x in s["tags"])
        out.append(f'''      <div class="srv-item">
        <div class="srv-num">{s["num"]}</div>
        <div class="srv-name">{s["name"]}<em>{s["sub"]}</em></div>
        <div class="srv-tags">
{tags}
        </div>
        <div class="srv-arrow">
          {ARROW}
        </div>
      </div>''')
    return "\n\n" + "\n\n".join(out) + "\n"
def service_links(l, t):
    links = " ".join(f'<a href="{service_url(l, s)}">{s["nav"][l]}</a>' for s in SERVICES)
    return f'<p class="srv-more" data-sr="u"><span>{t["srv_more_label"]}</span> {links}</p>'
def opts(items):
    return "\n".join(f'            <option>{x}</option>' for x in items)
def faq_items(t):
    return "\n".join(f'''      <details class="faq-item">
        <summary>{q}</summary>
        <p>{a}</p>
      </details>''' for q, a in t["faq"])
def process_steps(t):
    return "".join(f'<li><span class="lp-step-n">0{i+1}</span><strong>{a}</strong><span>{b}</span></li>' for i, (a, b) in enumerate(t["lp_steps"]))
def business_ld(l, t):
    org = {"@context": "https://schema.org", "@type": "ProfessionalService", "@id": DOMAIN + "/#business",
           "name": "A.D.Films24", "alternateName": "A.D.Films24 Studio", "slogan": "Capture More",
           "description": t["ld_desc"], "url": DOMAIN + home_url(l), "email": MAIL, "telephone": "+41767649300",
           "logo": DOMAIN + "/icon-512.png", "image": DOMAIN + "/og-image.png",
           "address": {"@type": "PostalAddress", "addressLocality": "Zürich", "addressCountry": "CH"},
           "areaServed": [{"@type": "City", "name": "Zürich"}, {"@type": "Country", "name": "Schweiz"}],
           "founder": {"@type": "Person", "name": "Abdi Dhiblawe"},
           "makesOffer": [{"@type": "Offer", "itemOffered": {"@type": "Service", "name": re.sub("&amp;", "&", sv["h1"][l]), "url": DOMAIN + service_url(l, sv)}} for sv in SERVICES],
           "sameAs": ["https://instagram.com/a.d.films24", "https://www.youtube.com/@adfilms24", t["google_url"]]}
    site = {"@context": "https://schema.org", "@type": "WebSite", "@id": DOMAIN + "/#website", "name": "A.D.Films24",
            "url": DOMAIN + "/", "inLanguage": ["de-CH", "en"], "publisher": {"@id": DOMAIN + "/#business"}}
    faq = {"@context": "https://schema.org", "@type": "FAQPage",
           "mainEntity": [{"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in t["faq"]]}
    return "\n".join(f'<script type="application/ld+json">{esc_json(x)}</script>' for x in (org, site, faq))
SIZES = ["xl", "tall", "wide", "wide", "sq", "sq"]
BGS = ["bg-a", "bg-b", "bg-c", "bg-d", "bg-e", "bg-f"]
def projects_grid(l, t):
    pub = [p for p in PROJECTS if p.get("published")]
    cells = []
    for i, p in enumerate(pub):
        poster = poster_of(p); vid = has_video(p)
        title = p["title"][l]
        style = f' style="background-image:linear-gradient(rgba(6,6,6,.25),rgba(6,6,6,.35)),url(\'{poster}\')"' if poster else ""
        bg = "pf-cell-bg has-img" if poster else f"pf-cell-bg {BGS[i % 6]}"
        glyph = "" if poster else f'<span class="pf-glyph">{title[:1]}</span>'
        play = '\n        <div class="pf-play"><svg width="22" height="24" viewBox="0 0 16 18" fill="none"><path d="M2 2L14 9L2 16V2Z" fill="#EDE9E0"/></svg></div>' if vid else ""
        size = "xl" if len(pub) == 1 else SIZES[i % 6]
        feat = " featured" if vid and poster else ""
        cells.append(f'''      <a class="pf-cell{feat}" href="{project_url(l, p["slug"])}" data-size="{size}" data-cat="{p["category"]}" aria-label="{title} — {tag_of(p, l)}">
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
            f'    <p class="soon-note" style="margin-top:2px;" data-sr="u">{t["portfolio_soon"]}</p>')

# ---------- Seiten ----------
def build_home(l):
    urls = {x: home_url(x) for x in LANGS}
    t = common_ctx(l, urls)
    t.update(ticker=ticker(t), marquee=marquee(t), gear=gear(t), services=services(t), service_links=service_links(l, t), projects_grid=projects_grid(l, t),
             business_ld=business_ld(l, t), process_steps=process_steps(t), faq_items=faq_items(t),
             project_type_opts=opts(t["project_types"]), budget_opts_html=opts(t["budget_opts"]), source_opts_html=opts(t["source_opts"]),
             footer_service_links="\n".join(f'      <li><a href="{service_url(l, sv)}">{sv["nav"][l]}</a></li>' for sv in SERVICES),
             year=datetime.date.today().year)
    keys = ["menu_open", "menu_close", "showreel_title", "showreel_desc", "showreel_client", "showreel_camera", "showreel_year",
            "form_wait", "form_sending", "form_sending_status", "form_sent_btn", "form_ok", "form_fail", "lbl_budget", "lbl_date", "lbl_source"]
    t["i18n_json"] = esc_json({**{k: TEXT[l][k] for k in keys}, "mail": MAIL, "lang": l})
    html = render((ROOT / "templates/home.html").read_text(encoding="utf-8"), t)
    write("index.html" if l == "de" else "en/index.html", html)

def page_shell(l, urls, title, desc, body, robots="index, follow", extra_head="", body_class="", css="legal.css"):
    t = common_ctx(l, urls)
    t.update(title=title, desc=desc, body=body, robots=robots, extra_head=extra_head, body_class=body_class, css=css,
             legal_back=TEXT[l]["legal_back"])
    return render((ROOT / "templates/page.html").read_text(encoding="utf-8"), t)

def footer_links(l):
    svc = "".join(f'\n    <a href="{service_url(l, sv)}">{sv["nav"][l]}</a>' for sv in SERVICES)
    return (f'<a href="{home_url(l)}">{TEXT[l]["legal_home"]}</a>{svc}\n    <a href="{LEGAL["imprint"][l]}">{TEXT[l]["foot_imprint"]}</a>\n'
            f'    <a href="{LEGAL["privacy"][l]}">{TEXT[l]["foot_privacy"]}</a>\n    <a href="{LEGAL["terms"][l]}">{TEXT[l]["foot_terms"]}</a>')
def breadcrumb_ld(l, items):
    return '<script type="application/ld+json">' + esc_json({"@context": "https://schema.org", "@type": "BreadcrumbList",
        "itemListElement": [{"@type": "ListItem", "position": i + 1, "name": n, "item": DOMAIN + u} for i, (n, u) in enumerate(items)]}) + '</script>'

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

CAT_SERVICE = {"commercial": "imagefilm-zuerich", "showreel": "imagefilm-zuerich", "social": "social-media-content-zuerich", "events": "event-video-zuerich"}
def build_projects():
    for p in PROJECTS:
        urls = {l: project_url(l, p["slug"]) for l in LANGS}
        for l in LANGS:
            t = TEXT[l]; vid = has_video(p); poster = poster_of(p)
            title = p["title"][l]; draft = not p.get("published")
            cat = t["categories"].get(p["category"], p["category"])
            if vid:
                pa = f' poster="{poster}"' if poster else ""
                video = f'<video controls playsinline preload="metadata"{pa}><source src="{vid}" type="video/mp4"></video>'
            else:
                video = f'<div class="pj-soon"><span>▶</span><p>{t["pj_soon"]}</p></div>'
            rows = []
            for lab, val in [("pj_category", cat), ("pj_client", p.get("client")), ("pj_year", p.get("year")), ("pj_camera", p.get("camera"))]:
                if val: rows.append(f'<div><dt>{t[lab]}</dt><dd>{val}</dd></div>')
            ld = ""
            if vid and not draft:
                ld = ('<script type="application/ld+json">' + esc_json({
                    "@context": "https://schema.org", "@type": "VideoObject", "name": title, "description": p["desc"][l],
                    "thumbnailUrl": (DOMAIN + poster) if poster else DOMAIN + "/og-image.png",
                    "uploadDate": p.get("uploadDate", "2026-01-01"), **({"duration": p["duration"]} if p.get("duration") else {}),
                    "contentUrl": DOMAIN + vid, "publisher": {"@type": "Organization", "name": "A.D.Films24", "url": DOMAIN + "/"}}) + '</script>')
            draft_note = f'<p class="pj-draft">{t["pj_draft"]}</p>' if draft else ""
            sv = next((x for x in SERVICES if x["slug"]["de"] == CAT_SERVICE.get(p["category"])), None)
            related = f'<p class="srv-more lp-more"><span>{t["pj_service"]}</span> <a href="{service_url(l, sv)}">{sv["nav"][l]}</a></p>' if sv else ""
            if not draft:
                ld += breadcrumb_ld(l, [(t["legal_home"], home_url(l)), (title, urls[l])])
            body = f'''<nav id="nav" class="pinned pj-nav">
    <a href="{home_url(l)}" class="nav-logo" aria-label="A.D. Films24"><img src="/logo.svg" alt="A.D. Films24" class="nav-logo-img"></a>
    <div class="nav-right">
      <a href="{home_url(l)}#portfolio" class="nav-lang pj-backlink">{t["pj_back"]}</a>
      <a href="{urls[other(l)]}" class="nav-lang" hreflang="{other(l)}" lang="{other(l)}" aria-label="{t["lang_switch_aria"]}">{t["lang_switch_label"]}</a>
    </div>
  </nav>
  <main id="main" tabindex="-1" class="pj">
    {draft_note}
    <p class="s-meta">{cat}</p>
    <h1 class="h-display pj-title">{title}</h1>
    <div class="pj-video">{video}</div>
    <div class="pj-body">
      <p class="pj-desc">{p["desc"][l]}</p>
      <dl class="pj-meta">{''.join(rows)}</dl>
    </div>
    <div class="pj-cta">
      <h2>{t["pj_cta_h"]}</h2>
      <a href="{home_url(l)}#contact" class="cta-primary">{ARROW} {t["pj_cta"]}</a>
    </div>
    {related}
    <footer class="page-foot pj-foot">
      {footer_links(l)}
    </footer>
  </main>'''
            html = page_shell(l, urls, f'{title} — A.D.Films24', p["desc"][l], body,
                              robots="noindex, nofollow" if draft else "index, follow", extra_head=ld, body_class="page-project", css="style.css")
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
                poster = poster_of(p); pa = f' poster="{poster}"' if poster else ""
                video = (f'<p class="s-meta lp-label">{t["lp_example"]}: <a href="{project_url(l, p["slug"])}">{p["title"][l]}</a></p>\n'
                         f'    <div class="pj-video"><video controls playsinline preload="metadata"{pa}><source src="{vid}" type="video/mp4"></video></div>')
            inc = "".join(f"<li>{x}</li>" for x in s["includes"][l])
            who = "".join(f"<li>{x}</li>" for x in s["for"][l])
            steps = "".join(f'<li><span class="lp-step-n">0{i+1}</span><strong>{a}</strong><span>{b}</span></li>' for i, (a, b) in enumerate(t["lp_steps"]))
            more = " ".join(f'<a href="{service_url(l, o)}">{o["nav"][l]}</a>' for o in SERVICES if o is not s)
            ld = '<script type="application/ld+json">' + esc_json({
                "@context": "https://schema.org", "@type": "Service", "name": re.sub(r"&amp;", "&", s["h1"][l]),
                "description": s["meta"][l], "areaServed": {"@type": "City", "name": "Zürich" if l == "de" else "Zurich"},
                "provider": {"@type": "Organization", "name": "A.D.Films24", "url": DOMAIN + "/"}, "url": DOMAIN + urls[l]}) + '</script>'
            body = f'''<nav id="nav" class="pinned pj-nav">
    <a href="{home_url(l)}" class="nav-logo" aria-label="A.D. Films24"><img src="/logo.svg" alt="A.D. Films24" class="nav-logo-img"></a>
    <div class="nav-right">
      <a href="{home_url(l)}#services" class="nav-lang pj-backlink">← {t["n_services"]}</a>
      <a href="{urls[other(l)]}" class="nav-lang" hreflang="{other(l)}" lang="{other(l)}" aria-label="{t["lang_switch_aria"]}">{t["lang_switch_label"]}</a>
    </div>
  </nav>
  <main id="main" tabindex="-1" class="pj lp">
    <p class="s-meta">{t["lp_meta"]}</p>
    <h1 class="h-display pj-title">{s["h1"][l]}</h1>
    <p class="lp-intro">{s["intro"][l]}</p>
    <div class="lp-cols">
      <div><h2 class="lp-h">{t["lp_includes"]}</h2><ul class="lp-list">{inc}</ul></div>
      <div><h2 class="lp-h">{t["lp_for"]}</h2><ul class="lp-list">{who}</ul></div>
    </div>
    {video}
    <h2 class="lp-h">{t["lp_process"]}</h2>
    <ol class="lp-steps">{steps}</ol>
    <p class="lp-promise">{t["lp_promise"]}</p>
    <div class="pj-cta">
      <h2>{t["lp_cta_h"]}</h2>
      <a href="{home_url(l)}#contact" class="cta-primary">{ARROW} {t["pj_cta"]}</a>
    </div>
    <p class="srv-more lp-more"><span>{t["lp_more"]}</span> {more}</p>
    <footer class="page-foot pj-foot">
      {footer_links(l)}
    </footer>
  </main>'''
            ld += breadcrumb_ld(l, [(t["legal_home"], home_url(l)), (t["n_services"], home_url(l) + "#services"), (re.sub("&amp;", "&", s["h1"][l]), urls[l])])
            html = page_shell(l, urls, s["title"][l], s["meta"][l], body, extra_head=ld, body_class="page-project", css="style.css")
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
    def entry(urls, prio, freq):
        alts = "".join(f'\n    <xhtml:link rel="alternate" hreflang="{l}" href="{DOMAIN}{u}"/>' for l, u in urls.items())
        alts += f'\n    <xhtml:link rel="alternate" hreflang="x-default" href="{DOMAIN}{urls["de"]}"/>'
        return "".join(f'  <url>\n    <loc>{DOMAIN}{urls[l]}</loc>{alts}\n    <lastmod>{datetime.date.today().isoformat()}</lastmod>\n    <changefreq>{freq}</changefreq>\n    <priority>{prio}</priority>\n  </url>\n' for l in LANGS)
    out = entry({l: home_url(l) for l in LANGS}, "1.0", "monthly")
    for p in PROJECTS:
        if p.get("published"): out += entry({l: project_url(l, p["slug"]) for l in LANGS}, "0.8", "monthly")
    for sv in SERVICES: out += entry({l: service_url(l, sv) for l in LANGS}, "0.9", "monthly")
    for k in LEGAL: out += entry({l: LEGAL[k][l] for l in LANGS}, "0.2", "yearly")
    write("sitemap.xml", '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n' + out + '</urlset>\n')

if __name__ == "__main__":
    for l in LANGS: build_home(l)
    build_legal(); build_projects(); build_services(); build_404(); build_sitemap()
    n_pub = sum(1 for p in PROJECTS if p.get("published"))
    print(f"OK: 2 Startseiten, {n_pub} veröffentlichte + {len(PROJECTS)-n_pub} Entwurf-Projekte (je DE/EN), {len(SERVICES)} Leistungsseiten, Rechtstexte, 404, Sitemap")
