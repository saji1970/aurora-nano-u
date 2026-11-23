"""Draw the Aurora glasses main-board block diagram as SVG and PNG.

Run: python3 scripts/glasses_board_diagram.py   (PNG needs: pip install cairosvg)
"""
import pathlib

W, H = 1600, 1000
FONT = "Inter, Helvetica, Arial, sans-serif"
INK, MUTED, LINE = "#111", "#555", "#b9b9ae"
BLUE_FILL, BLUE_LINE = "#e6eef8", "#2f6fd1"
out = []


def text(x, y, s, size=15, weight=400, color=INK, anchor="middle"):
    s = s.replace("&", "&amp;")
    out.append(f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
               f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{s}</text>')


def box(x1, y1, x2, y2, title, lines=(), fill="#fff", stroke=LINE, sw=1.5, dash=None, title_y=None):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(f'<rect x="{x1}" y="{y1}" width="{x2-x1}" height="{y2-y1}" rx="10" '
               f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    cx = (x1 + x2) / 2
    n = 1 + len(lines)
    ty = title_y or (y1 + y2) / 2 - (n - 1) * 11 + 5
    text(cx, ty, title, 17, 600)
    for i, l in enumerate(lines):
        text(cx, ty + 24 + i * 21, l, 14, 400, MUTED)


def arrow(points, both=True, label=None, lx=None, ly=None, anchor="start"):
    pts = " ".join(f"{x},{y}" for x, y in points)
    ms = ' marker-start="url(#a)"' if both else ""
    out.append(f'<polyline points="{pts}" fill="none" stroke="{LINE}" stroke-width="1.6"'
               f'{ms} marker-end="url(#a)"/>')
    if label:
        text(lx, ly, label, 13, 500, MUTED, anchor)


out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
out.append('<defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
           f'orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="{LINE}"/></marker></defs>')
out.append(f'<rect width="{W}" height="{H}" fill="#fff"/>')
text(40, 52, "Aurora glasses main board: one Android SoC drives the displays, 5G modem and 16 GB of memory",
     24, 700, INK, "start")
text(40, 84, "System block diagram; arrows are the buses between chips. Example part classes, not a layout.",
     16, 400, MUTED, "start")

# Row A: user-facing peripherals
box(40, 120, 320, 220, "Touch controller", ["temple touchpad or touch panel", "capacitive, multi-touch"])
box(380, 120, 790, 220, "Left lens display", ["microLED projector + waveguide", "display driver / bridge"])
box(810, 120, 1220, 220, "Right lens display", ["microLED projector + waveguide", "display driver / bridge"])
box(1280, 120, 1560, 220, "Cameras", ["RGB camera", "eye + hand tracking"])

# Row B: SoC, memory, storage, NPU
box(40, 300, 320, 480, "16 GB LPDDR5X", ["4 × 16-bit channels", "8533 MT/s, 68 GB/s", "package-on-package"])
out.append(f'<rect x="380" y="300" width="840" height="180" rx="10" fill="{BLUE_FILL}" '
           f'stroke="{BLUE_LINE}" stroke-width="2"/>')
text(800, 330, "Application processor (SoC)", 19, 700)
text(800, 352, "runs Android; Snapdragon XR2 Gen 2-class", 14, 400, MUTED)
for i, (t, a, b) in enumerate([("CPU", "8 cores, Arm v9", "Android OS + apps"),
                               ("GPU", "Adreno, Vulkan 1.3", "renders both eyes"),
                               ("NPU / DSP", "Hexagon", "vision, voice"),
                               ("ISP + display", "camera pipeline", "dual-display engine")]):
    x = 400 + i * 205
    box(x, 368, x + 185, 466, t, [a, b], sw=1.2, title_y=395)
box(1280, 300, 1560, 380, "Storage", ["UFS 4.0, 256 GB"])
box(1280, 400, 1560, 480, "Aurora-Nano NPU", ["optional LLM co-processor"])

# Row C: radios, audio
box(40, 560, 320, 660, "RF front end", ["PA, LNA, filters, tuners", "antennas in the frame"])
box(380, 560, 820, 660, "5G modem-RF", ["Snapdragon X75-class", "sub-6 GHz + mmWave, eSIM"])
box(880, 560, 1220, 660, "Wi-Fi 7 + Bluetooth 5.4", ["phone tether, accessories"])
box(1280, 560, 1560, 660, "Audio + sensors", ["mics, speakers, IMU", "ambient light, proximity"])

# Row D: power
out.append(f'<rect x="40" y="720" width="1520" height="190" rx="12" fill="#f6f8f3" '
           f'stroke="{LINE}" stroke-width="1.5" stroke-dasharray="6 5"/>')
text(60, 748, "Power and battery", 15, 700, "#3d6b2a", "start")
box(60, 765, 260, 885, "USB-C", ["or pogo pins", "5–9 V input"])
box(290, 765, 540, 885, "Charger IC", ["USB PD, 1–2 A", "JEITA temp. limits"])
box(570, 765, 780, 885, "Battery", ["Li-ion, 2 cells", "in the temples", "fuel gauge + protection"])
box(810, 765, 1150, 885, "PMIC + companion PMIC", ["~20 buck / LDO rails", "for every block above"])
box(1180, 765, 1540, 885, "Thermal guard", ["skin-temperature sensors", "SoC throttles at the limit"])

# Buses
arrow([(180, 220), (180, 260), (440, 260), (440, 300)], False, "I2C + interrupt", 190, 252)
arrow([(585, 300), (585, 220)], False, "MIPI DSI", 593, 265)
arrow([(1015, 300), (1015, 220)], False, "MIPI DSI", 1023, 265)
arrow([(1420, 220), (1420, 260), (1160, 260), (1160, 300)], False, "MIPI CSI-2", 1410, 252, "end")
arrow([(320, 390), (380, 390)])
arrow([(1220, 340), (1280, 340)], label="UFS", lx=1250, ly=332, anchor="middle")
arrow([(1220, 440), (1280, 440)], label="USB/SPI", lx=1250, ly=432, anchor="middle")
arrow([(600, 480), (600, 560)], label="PCIe Gen 3", lx=608, ly=525)
arrow([(1050, 480), (1050, 560)], label="PCIe + UART", lx=1058, ly=525)
arrow([(1420, 560), (1420, 520), (1180, 520), (1180, 480)], label="SoundWire, I3C", lx=1430, ly=545)
arrow([(320, 610), (380, 610)])
arrow([(260, 825), (290, 825)], False)
arrow([(540, 825), (570, 825)], False)
arrow([(780, 825), (810, 825)], False)
arrow([(850, 765), (850, 480)], False, "supply rails + SPMI", 858, 700)
arrow([(1180, 825), (1150, 825)], False)

text(40, 950, "Shaded: inside the one SoC package. Dashed: the power section, which feeds every block "
     "through the PMIC rails.", 14, 400, MUTED, "start")
text(40, 972, "Part names are examples of the class needed; confirm against vendor datasheets "
     "before a schematic.", 14, 400, MUTED, "start")
out.append("</svg>")

svg = "\n".join(out)
root = pathlib.Path(__file__).resolve().parent.parent / "docs" / "images"
(root / "glasses-board-block-diagram.svg").write_text(svg)
try:
    import cairosvg
    cairosvg.svg2png(bytestring=svg.encode(), write_to=str(root / "glasses-board-block-diagram.png"),
                     output_width=W * 2)
except ImportError:
    print("cairosvg not installed: wrote SVG only")
