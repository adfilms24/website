#!/usr/bin/env python3
"""Prüft die gebauten Seiten: jede interne Verlinkung/Asset existiert, jede Seite
hat <title> und lang, jede Sitemap-URL zeigt auf eine Datei.

    python3 tests/check_site.py
"""
import re, sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parent.parent
SKIP_DIRS = {"templates", "content", "tests", ".git", ".trash", "node_modules", ".vercel"}
URL_ATTRS = {"href", "src", "poster", "data-src"}


class Collector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.urls, self.lang, self.title = [], None, False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "html":
            self.lang = a.get("lang")
        if tag == "title":
            self.title = True
        if tag == "meta":  # og:image etc. zeigen auf die eigene Domain
            return
        for k, v in attrs:
            if v and k in URL_ATTRS:
                self.urls.append(v)
            if v and k == "srcset":
                self.urls += [part.strip().split(" ")[0] for part in v.split(",") if part.strip()]


def target_file(url: str, page: Path) -> Path | None:
    if url.startswith(("http://", "https://", "mailto:", "tel:", "data:", "#", "javascript:", "//")):
        return None
    path = urlsplit(url).path
    if not path:
        return None
    base = ROOT if path.startswith("/") else page.parent
    f = (base / path.lstrip("/")).resolve()
    return f / "index.html" if path.endswith("/") else f


def html_pages():
    for p in ROOT.rglob("*.html"):
        if not SKIP_DIRS.intersection(p.relative_to(ROOT).parts):
            yield p


def main() -> int:
    errors = []
    pages = sorted(html_pages())
    for page in pages:
        rel = page.relative_to(ROOT)
        c = Collector()
        c.feed(page.read_text(encoding="utf-8"))
        if not c.lang:
            errors.append(f"{rel}: <html> ohne lang")
        if not c.title:
            errors.append(f"{rel}: kein <title>")
        for url in c.urls:
            f = target_file(url, page)
            if f is not None and not f.exists():
                errors.append(f"{rel}: Ziel fehlt -> {url}")

    sitemap = (ROOT / "sitemap.xml").read_text(encoding="utf-8")
    for loc in re.findall(r"<loc>(.*?)</loc>", sitemap):
        f = target_file(urlsplit(loc).path or "/", ROOT / "index.html")
        if f is None or not f.exists():
            errors.append(f"sitemap.xml: Ziel fehlt -> {loc}")

    for e in errors:
        print("FEHLER", e)
    print(f"{len(pages)} Seiten geprüft, {len(errors)} Fehler")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
