#!/usr/bin/env python3
"""Erzeugt Vorschaubilder (1200x630) für Leistungs- und Projektseiten in og/.

    python3 tools/make_og.py   # danach python3 build.py

Braucht Pillow. Bilder nur neu erzeugen, wenn sich Titel oder Titelbilder ändern.
"""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
BEBAS = str(ROOT / "tools/BebasNeue-Regular.ttf")
W, H = 1200, 630
BONE, VOID = (237, 233, 224), (6, 6, 6)

def card(bg_path, kicker, title, out):
    bg = Image.open(bg_path).convert("RGB")
    s = max(W / bg.width, H / bg.height)
    bg = bg.resize((int(bg.width * s) + 1, int(bg.height * s) + 1))
    bg = bg.crop(((bg.width - W) // 2, (bg.height - H) // 2, (bg.width - W) // 2 + W, (bg.height - H) // 2 + H))
    shade = Image.new("L", (W, H))
    for x in range(W):  # links dunkel, rechts Bild sichtbar
        shade.paste(int(235 - 150 * x / W), (x, 0, x + 1, H))
    img = Image.composite(Image.new("RGB", (W, H), VOID), bg, shade)
    d = ImageDraw.Draw(img)
    d.text((72, 70), kicker.upper(), font=ImageFont.truetype(BEBAS, 34), fill=(190, 186, 178), spacing=4)
    size, lines = 118, title.upper().split("\n")
    font = ImageFont.truetype(BEBAS, size)
    while max(d.textlength(l, font=font) for l in lines) > W - 160:
        size -= 4; font = ImageFont.truetype(BEBAS, size)
    y = H - 110 - len(lines) * size * 0.92
    for l in lines:
        d.text((72, y), l, font=font, fill=BONE); y += size * 0.92
    d.text((72, H - 82), "ADFILMS24.CH  ·  CAPTURE MORE.", font=ImageFont.truetype(BEBAS, 30), fill=(160, 156, 148))
    out.parent.mkdir(exist_ok=True)
    img.save(out, "JPEG", quality=85, optimize=True)

def poster(slug):
    p = ROOT / f"assets/video/projects/{slug}.jpg"
    return p if p.exists() else ROOT / "assets/video/showreel-poster.jpg"

projects = {p["slug"]: p for p in json.loads((ROOT / "content/projects.json").read_text())}
for sv in json.loads((ROOT / "content/leistungen.json").read_text()):
    title = sv["h1"]["de"].replace("&amp;", "&").replace(" in Zürich", "\nin Zürich")
    card(poster(sv["project"] if sv["project"] != "showreel-2026" else "x"), "A.D.Films24 · Leistung", title, ROOT / f"og/{sv['slug']['de']}.jpg")
for p in projects.values():
    if p.get("published"):
        card(poster(p["slug"]), "A.D.Films24 · Projekt", p["title"]["de"].replace(" — ", "\n"), ROOT / f"og/{p['slug']}.jpg")
print("OK:", len(list((ROOT / "og").glob("*.jpg"))), "Vorschaubilder in og/")
