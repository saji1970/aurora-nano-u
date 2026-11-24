"""Draw where the boards, battery, antennas and displays sit in the Aurora glasses frame.

Run: python3 scripts/glasses_packaging_diagram.py   (PNG needs: pip install cairosvg)
Sizes are planning estimates in millimetres, drawn to scale within each panel.
"""
import pathlib

W, H = 1600, 900
FONT = "Inter, Helvetica, Arial, sans-serif"
INK, MUTED, LINE = "#111", "#555", "#9a9a90"
C = {"board": "#cfe0f6", "board_s": "#2f6fd1", "batt": "#d7ecc9", "batt_s": "#4f8a2f",
     "ant": "#fbe3c8", "ant_s": "#c2711d", "spk": "#e6dcf3", "spk_s": "#7a55b0",
     "frame": "#ecece6", "hinge": "#c9c9c0", "proj": "#3a3a3a"}
out = []


def text(x, y, s, size=14, weight=400, color=INK, anchor="start"):
    s = s.replace("&", "&amp;")
    out.append(f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
               f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{s}</text>')


def rect(x1, y1, x2, y2, fill, stroke=LINE, sw=1.2, rx=3, dash=None):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(f'<rect x="{x1}" y="{y1}" width="{x2-x1}" height="{y2-y1}" rx="{rx}" '
               f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')


def line(x1, y1, x2, y2, color=LINE, sw=1.2, dash=None):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="{sw}"{d}/>')


def label(px, py, tx, ty, lines, anchor="start"):
    """Leader line from a point to a two-line label."""
    line(px, py, tx, ty - 4)
    text(tx + (6 if anchor == "start" else -6), ty, lines[0], 14, 600, INK, anchor)
    for i, l in enumerate(lines[1:]):
        text(tx + (6 if anchor == "start" else -6), ty + 18 * (i + 1), l, 13, 400, MUTED, anchor)


out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
out.append(f'<rect width="{W}" height="{H}" fill="#fff"/>')
text(40, 52, "The boards go in the front of each arm, the battery cells behind the ears, the displays at the hinges",
     23, 700)
text(40, 84, "Aurora glasses packaging plan. Sizes are planning estimates in mm; each panel is drawn to its own scale.",
     16, 400, MUTED)

# ---------- Panel A: top view, 2 px per mm ----------
text(40, 130, "A. Top view, looking down on the glasses", 17, 700)
s, top = 2.0, 200          # scale, y where the arms start
fx1, fx2 = 250, 530        # front frame, 140 mm wide
rect(fx1, top - 20, fx2, top, C["frame"], rx=6)                     # front frame, 10 mm deep
for x in (fx1, fx2 - 14):                                           # arms, 7 mm thick, 145 mm long
    z = [(0, 6, C["hinge"], LINE), (6, 66, C["board"], C["board_s"]), (66, 80, C["ant"], C["ant_s"]),
         (80, 94, C["spk"], C["spk_s"]), (94, 140, C["batt"], C["batt_s"]), (140, 145, C["frame"], LINE)]
    for a, b, f, st in z:
        rect(x, top + a * s, x + 14, top + b * s, f, st, 1.2, 2)
for x in (fx1 + 3, fx2 - 25):                                       # projectors in the end pieces
    rect(x, top - 18, x + 22, top - 3, C["proj"], C["proj"], 1, 2)
for x in (fx1 + 36, fx2 - 36):                                      # cameras
    out.append(f'<circle cx="{x}" cy="{top-14}" r="5" fill="#fff" stroke="{INK}" stroke-width="1.5"/>')
rect(350, top - 26, 430, top - 20, C["ant"], C["ant_s"], 1.2, 2)    # antenna strip on top of the bridge
line(fx1 + 14, top - 8, fx2 - 14, top - 8, C["board_s"], 1.6, "5 4")  # frame flex

label(fx1 + 8, top - 12, 236, 166, ["microLED projector", "in each end piece"], "end")
label(450, top - 14, 560, 150, ["Cameras + frame flex", "display and camera links"])
label(390, top - 26, 390, 160, [""])  # short tick to the antenna strip
text(390, 146, "5G antenna strip", 13, 600, INK, "middle")
label(fx1, top + 36 * s, 240, top + 36 * s, ["Radio board", "5G modem, RF, Wi-Fi,", "charger, audio"], "end")
label(fx2, top + 36 * s, 540, top + 36 * s, ["Main board", "SoC + 16 GB, storage,", "PMIC, touchpad"])
label(fx1, top + 73 * s, 240, top + 73 * s + 12, ["Antennas", "plastic window, no metal"], "end")
label(fx2, top + 87 * s, 540, top + 87 * s, ["Open-ear speaker", "just in front of the ear"])
label(fx1, top + 117 * s, 240, top + 117 * s, ["Battery cell", "behind the ear, ~1.3 Wh"], "end")
label(fx2, top + 117 * s, 540, top + 117 * s, ["Battery cell", "balances the front weight"])
label(fx1 + 7, top + 3 * s, 240, top + 6 * s - 4, ["Hinge", ""], "end")
text(fx1 - 6 - 0, top + 6 * s + 14, "flex loops through", 13, 400, MUTED, "end")

# ---------- Panel B: right arm side view, 4.6 px per mm ----------
text(760, 130, "B. Right arm from the side, to scale", 17, 700)
k, x0 = 4.6, 850
X = lambda mm: x0 + mm * k
# arm outline: 16 mm tall at the hinge tapering to 11 mm at the tip
out.append(f'<polygon points="{X(0)},196 {X(145)},207 {X(145)},258 {X(0)},270" fill="#f7f7f3" '
           f'stroke="{INK}" stroke-width="1.5"/>')
rect(X(-8), 186, X(0), 282, C["frame"], LINE, 1.2, 3)               # end piece of the front frame
rect(X(-7), 214, X(-1), 244, C["proj"], C["proj"], 1, 1)            # projector
rect(X(0), 200, X(6), 266, C["hinge"], LINE, 1, 2)                  # hinge
rect(X(6), 203, X(66), 263, C["board"], C["board_s"], 1.4, 3)      # main board 60 x 13 mm
rect(X(10), 206, X(22), 260, "#fff", C["board_s"], 1.2, 2)          # SoC + memory 12 x 12
text((X(10) + X(22)) / 2, 230, "SoC", 13, 700, INK, "middle")
text((X(10) + X(22)) / 2, 246, "+16 GB", 12, 400, MUTED, "middle")
rect(X(26), 208, X(36), 236, "#fff", C["board_s"], 1.2, 2)
text((X(26) + X(36)) / 2, 226, "PMIC", 12, 600, INK, "middle")
rect(X(40), 207, X(52), 259, "none", C["board_s"], 1.2, 2, "4 3")   # UFS on the underside
text((X(40) + X(52)) / 2, 237, "UFS", 12, 600, INK, "middle")
rect(X(8), 199, X(64), 267, "none", "#888", 1.2, 4, "2 3")          # touchpad on the outer face
rect(X(66), 202, X(80), 262, C["ant"], C["ant_s"], 1.2, 2)
rect(X(80), 206, X(94), 258, C["spk"], C["spk_s"], 1.2, 2)
rect(X(95), 210, X(141), 256, C["batt"], C["batt_s"], 1.4, 4)     # cell 46 x 10 mm
text((X(95) + X(141)) / 2, 238, "Li-ion cell 46 × 10 × 6 mm", 13, 600, INK, "middle")
# dimension line and zone names
line(X(0), 300, X(145), 300, INK, 1)
for mm in (0, 6, 66, 80, 94, 145):
    line(X(mm), 294, X(mm), 306, INK, 1)
text((X(0) + X(145)) / 2, 292, "arm 145 mm", 13, 600, INK, "middle")
for mm, a, b in [(36, "main board 60 × 13 mm", "touchpad over it (dotted)"), (73, "antennas", "14 mm"),
                 (87, "speaker", ""), (118, "battery", "~1.3 Wh")]:
    yy = 326 if mm != 87 else 362
    text(X(mm), yy, a, 13, 600, INK, "middle")
    if b:
        text(X(mm), yy + 17, b, 12, 400, MUTED, "middle")
text(X(-9), 228, "projector", 12, 600, INK, "end")
text(X(-9), 244, "+ hinge", 12, 400, MUTED, "end")
text(X(0) + 4, 188, "16 mm tall", 12, 400, MUTED)
text(X(145), 200, "11 mm at the tip", 12, 400, MUTED, "end")
text(X(87), 400, "▲ the ear sits under here; the tip bends down behind it", 12, 400, MUTED, "middle")

# ---------- Panel C: cross-section at the SoC, 30 px per mm ----------
text(760, 470, "C. Cross-section of the arm at the SoC: about 6 mm thick", 17, 700)
layers = [("Outer shell + touch sensor", "0.9 mm, plastic or ceramic", 0.9, "#ecece6"),
          ("Graphite sheet + shield lid", "0.3 mm, spreads heat outward", 0.3, "#555"),
          ("SoC with 16 GB stacked on top", "1.4 mm, the tallest part", 1.4, C["board"]),
          ("Circuit board, 10–12 layer HDI", "0.8 mm", 0.8, "#7aa36a"),
          ("Underside parts: UFS, PMIC", "1.0 mm", 1.0, C["board"]),
          ("Shield can", "0.2 mm", 0.2, "#888"),
          ("Air gap + insulation", "0.6 mm, keeps the skin side cool", 0.6, "#fff"),
          ("Inner shell, skin side", "0.8 mm", 0.8, "#ecece6")]
y, kx, sx1, sx2 = 500, 30, 800, 980
text(sx1, 494, "outside", 12, 600, MUTED)
for i, (name, note, t, fill) in enumerate(layers):
    rect(sx1, y, sx2, y + t * kx, fill, "#999", 0.8, 0)
    ly = 506 + i * 24
    line(sx2, y + t * kx / 2, sx2 + 30, ly - 4)
    text(sx2 + 36, ly, name, 13, 600)
    text(sx2 + 260, ly, note, 13, 400, MUTED)
    y += t * kx
text(sx1, y + 18, "skin side", 12, 600, MUTED)

# ---------- Panel D: key numbers ----------
text(40, 600, "D. What the whole pair adds up to", 17, 700)
rows = [("Battery", "2 cells × ~1.3 Wh = ~2.6 Wh"),
        ("Board area", "2 boards × 60 × 13 mm, both sides used"),
        ("Weight", "about 65–85 g; normal glasses 25–35 g"),
        ("Heat the arms can shed", "about 1 W each without feeling warm"),
        ("Charging", "pogo pins under the arm, in a case")]
for i, (a, b) in enumerate(rows):
    text(40, 636 + i * 26, a, 14, 600)
    text(250, 636 + i * 26, b, 14, 400, MUTED)

text(40, 800, "Left arm mirrors panel B with the radio board (5G modem, RF front end, Wi-Fi/Bluetooth, charger, audio) "
     "in place of the main board.", 14, 400, MUTED)
text(40, 822, "Colours: blue boards, orange antennas, purple speakers, green battery cells, "
     "dark grey microLED projectors.", 14, 400, MUTED)
out.append("</svg>")

svg = "\n".join(out)
root = pathlib.Path(__file__).resolve().parent.parent / "docs" / "images"
(root / "glasses-packaging.svg").write_text(svg)
try:
    import cairosvg
    cairosvg.svg2png(bytestring=svg.encode(), write_to=str(root / "glasses-packaging.png"), output_width=W * 2)
except ImportError:
    print("cairosvg not installed: wrote SVG only")
