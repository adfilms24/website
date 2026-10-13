#!/usr/bin/env python3
"""Erzeugt die Logo-Dateien (dunkle Version) aus den Website-Schriften.

    python3 tools/make_logo.py

  logo.svg          Kompakt (Variante C): Zeichen, AD24 und Slogan auf einer Linie, für die Navigation
  logo-primary.svg  Hauptlogo (Variante A): AD24 mit Slogan darunter, für Offerten, Abspann usw.
  favicon.svg       Zeichen auf dunklem Grund

Schrift wird in Pfade umgewandelt, damit die Dateien überall gleich aussehen.
Braucht fonttools und brotli (pip install fonttools brotli).
"""
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.transformPen import TransformPen
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parent.parent
FONTS = ROOT / "assets/fonts"
SERIF = TTFont(FONTS / "jizBRFtNs2ka5fXjeivQ4LroWlx-6zUTjnTLgNs.woff2")
MONO_VF = FONTS / "tDbV2o-flEEny0FZhsfKu5WU4xD7OwGtT0rU.woff2"
MONO_400 = instantiateVariableFont(TTFont(MONO_VF), {"wght": 400})
MONO_500 = instantiateVariableFont(TTFont(MONO_VF), {"wght": 500})

BONE, BRONZE, DARK = "#EDE9E0", "#C8A47E", "#161616"


def text(font, s, x, y, size, spacing=0.0):
    """Gibt (SVG-Pfad, Tinten-Box) für einen Text ab Grundlinie y zurück."""
    gs, cmap = font.getGlyphSet(), font.getBestCmap()
    k = size / font["head"].unitsPerEm
    svg, bounds = SVGPathPen(gs), BoundsPen(gs)
    pen_x = x
    for ch in s:
        name = cmap[ord(ch)]
        t = (k, 0, 0, -k, pen_x, y)
        gs[name].draw(TransformPen(svg, t))
        gs[name].draw(TransformPen(bounds, t))
        pen_x += gs[name].width * k + spacing
    return svg.getCommands(), bounds.bounds


def spread(font, s, x0, x1, y, size):
    """Setzt einen Text so gesperrt, dass seine Tinte genau von x0 bis x1 reicht."""
    _, (bx0, _, bx1, _) = text(font, s, 0, y, size)
    gap = (x1 - x0 - (bx1 - bx0)) / (len(s) - 1)
    return text(font, s, x0 - bx0, y, size, gap)


def mark(sw, x, y, size, color):
    """Das Zeichen aus dem alten Logo, im 32er Raster nachgebaut, mit Strichstärke sw."""
    h = sw / 2
    sq = "".join(f'<rect x="{qx + h:g}" y="{qy + h:g}" width="{6 - sw:g}" height="{6 - sw:g}"/>'
                 for qx, qy in ((26, 0), (26, 26), (0, 26)))
    return (f'<g transform="translate({x:g} {y:g}) scale({size / 32:g})" fill="none" stroke="{color}" '
            f'stroke-width="{sw:g}">{sq}<path d="M6 26 26 6M16 16 26 26"/></g>')


def union(*boxes):
    return (min(b[0] for b in boxes), min(b[1] for b in boxes),
            max(b[2] for b in boxes), max(b[3] for b in boxes))


def write(name, label, body, box, pad=2):
    x0, y0, x1, y1 = box[0] - pad, box[1] - pad, box[2] + pad, box[3] + pad
    w, h = x1 - x0, y1 - y0
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x0:.2f} {y0:.2f} {w:.2f} {h:.2f}" '
           f'width="{w:.0f}" height="{h:.0f}" role="img" aria-label="{label}"><title>{label}</title>{body}</svg>\n')
    (ROOT / name).write_text(svg)
    print(f"{name}: {w:.0f} x {h:.0f}")


# Hauptlogo (A): Zeichen links, AD24 gross, Slogan auf Schriftbreite gesperrt
word, wb = text(SERIF, "AD24", 124, 70, 94, 1)
tag, tb = spread(MONO_400, "CAPTURE MORE", wb[0] + 2, wb[2] - 2, 99, 12.5)
write("logo-primary.svg", "A.D.Films24 – Capture More",
      mark(1.5, 0, 0, 100, BRONZE)
      + f'<path fill="{BONE}" d="{word}"/><path fill="{BONE}" fill-opacity=".8" d="{tag}"/>',
      union((0, 0, 100, 100), wb, tb))

# Kompakt (C): Zeichen, AD24, Trennstrich, Slogan zweizeilig
word, wb = text(SERIF, "AD24", 64, 52, 66)
rx = wb[2] + 18
l1, b1 = text(MONO_500, "CAPTURE", rx + 18, 27, 15, 3.2)
l2, b2 = text(MONO_500, "MORE", rx + 18, 51, 15, 3.2)
write("logo.svg", "A.D.Films24 – Capture More",
      mark(2, 0, 4, 48, BRONZE)
      + f'<path fill="{BONE}" d="{word}"/>'
      + f'<rect x="{rx - 0.75:.2f}" y="10" width="1.5" height="42" fill="{BRONZE}"/>'
      + f'<path fill="{BONE}" d="{l1}{l2}"/>',
      union((0, 4, 48, 52), wb, b1, b2, (rx, 10, rx, 52)))

# Favicon: Zeichen auf dunklem Grund, kräftige Linie für kleine Grössen
(ROOT / "favicon.svg").write_text(
    '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">'
    f'<rect width="512" height="512" rx="96" fill="{DARK}"/>{mark(2.6, 112, 112, 288, BRONZE)}</svg>\n')
print("favicon.svg")
