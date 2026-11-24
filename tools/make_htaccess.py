#!/usr/bin/env python3
"""Baut die .htaccess für Infomaniak (Apache) aus vercel.json, damit Header und Weiterleitungen an einer Stelle gepflegt werden.

Aufruf: python3 tools/make_htaccess.py [Zieldatei]   (Standard: .htaccess im Repo-Ordner, wird nicht committet)
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def to_regex(src):
    # Vercel-Muster wie /(.*) oder /assets/(video|js)/(.*) sind schon fast Regex; nur Punkte maskieren
    body = src.lstrip("/")
    out, depth = "", 0
    for ch in body:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "." and depth == 0:
            out += r"\."
        else:
            out += ch
    return "^/?" + out + "$"


def build(cfg):
    L = [
        "# Automatisch erzeugt aus vercel.json durch tools/make_htaccess.py. Nicht von Hand ändern.",
        "Options -Indexes -MultiViews",
        "DirectoryIndex index.html",
        "ErrorDocument 404 /404.html",
        "",
        "RewriteEngine On",
        "# Immer HTTPS",
        "RewriteCond %{HTTPS} !=on",
        "RewriteCond %{HTTP:X-Forwarded-Proto} !=https",
        "RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]",
        "# adfilms24.ch → www.adfilms24.ch (Canonical der Seiten ist www)",
        "RewriteCond %{HTTP_HOST} ^adfilms24\\.ch$ [NC]",
        "RewriteRule ^ https://www.adfilms24.ch%{REQUEST_URI} [R=301,L]",
        "",
        "# Weiterleitungen aus vercel.json",
    ]
    for r in cfg.get("redirects", []):
        code = 301 if r.get("permanent", True) else 302
        L.append(f"RewriteRule {to_regex(r['source'])} {r['destination']} [R={code},L]")
    L += [
        "",
        "# Kontaktformular: /api/anfrage → PHP; Schlüssel-Datei nie ausliefern",
        "RewriteRule ^api/config\\.php$ - [F,L]",
        "RewriteRule ^api/anfrage/?$ api/anfrage.php [L]",
        "",
        "# Adressen ohne .html (z.B. /impressum) wie auf Vercel bedienen",
        "RewriteCond %{REQUEST_FILENAME} !-f",
        "RewriteCond %{REQUEST_FILENAME} !-d",
        "RewriteCond %{REQUEST_FILENAME}.html -f",
        "RewriteRule ^(.+?)/?$ $1.html [L]",
        "",
        "<IfModule mod_headers.c>",
    ]
    for h in cfg.get("headers", []):
        rx = to_regex(h["source"])
        for kv in h["headers"]:
            val = kv["value"].replace('"', '\\"')
            if h["source"] == "/(.*)":
                L.append(f'  Header always set {kv["key"]} "{val}"')
            else:
                L.append(f'  <If "%{{REQUEST_URI}} =~ m#{rx}#">')
                L.append(f'    Header set {kv["key"]} "{val}"')
                L.append("  </If>")
    L += ["</IfModule>", ""]
    return "\n".join(L)


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / ".htaccess"
    target.write_text(build(json.loads((ROOT / "vercel.json").read_text())))
    print(f"{target} geschrieben")
