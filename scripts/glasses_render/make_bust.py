"""Build stylised mannequin busts for the on-model renders.

The busts are signed-distance sculptures (smoothly blended ellipsoids and
capsules) meshed with marching cubes. They are deliberately abstract, like a
retail display head, so they depict no real person. Units are millimetres in
the same frame as glasses.html: lens centres at (+-34, 0, 0), +z towards the
viewer, +y up.

    python3 make_bust.py            # writes bust-<name>-{skin,hair}.bin

Each .bin holds: uint32 vertex count, uint32 index count, float32 positions,
float32 normals, uint32 indices.
"""
import struct
import sys

import numpy as np
from skimage import measure

RES = 1.3  # mm per voxel


def grid():
    xs = np.arange(-210, 210, RES, dtype=np.float32)
    ys = np.arange(-340, 150, RES, dtype=np.float32)
    zs = np.arange(-230, 40, RES, dtype=np.float32)
    X, Y, Z = np.meshgrid(xs, ys, zs, indexing="ij")
    return (xs, ys, zs), X, Y, Z


def ell(X, Y, Z, c, r):
    """Approximate SDF of an ellipsoid (good near the surface)."""
    px, py, pz = (X - c[0]) / r[0], (Y - c[1]) / r[1], (Z - c[2]) / r[2]
    k0 = np.sqrt(px * px + py * py + pz * pz)
    k1 = np.sqrt((px / r[0]) ** 2 + (py / r[1]) ** 2 + (pz / r[2]) ** 2)
    return k0 * (k0 - 1.0) / np.maximum(k1, 1e-6)


def cap(X, Y, Z, a, b, ra, rb):
    a, b = np.array(a, np.float32), np.array(b, np.float32)
    ba = b - a
    px, py, pz = X - a[0], Y - a[1], Z - a[2]
    h = np.clip((px * ba[0] + py * ba[1] + pz * ba[2]) / ba.dot(ba), 0, 1)
    dx, dy, dz = px - ba[0] * h, py - ba[1] * h, pz - ba[2] * h
    return np.sqrt(dx * dx + dy * dy + dz * dz) - (ra + (rb - ra) * h)


def smin(a, b, k):
    h = np.clip(0.5 + 0.5 * (b - a) / k, 0, 1)
    return b + (a - b) * h - k * h * (1 - h)


def smax(a, b, k):
    return -smin(-a, -b, k)


def head(X, Y, Z, p):
    w = p["width"]   # 1.0 = default proportions
    jaw = p["jaw"]
    d = ell(X, Y, Z, (0, 30, -104), (66 * w, 90, 100))                         # cranium
    d = smin(d, ell(X, Y, Z, (0, -22, -62), (54 * w, 72, 56)), 18)              # face mass
    d = smin(d, ell(X, Y, Z, (0, 13, -15), (52 * w, 11, 12)), 10)               # brow
    for s in (-1, 1):
        d = smin(d, ell(X, Y, Z, (s * 42 * w, -20, -36), (19, 15, 22)), 12)     # cheekbones
    d = smin(d, ell(X, Y, Z, (0, -62, -64), (48 * w * jaw, 32, 50)), 20)       # jaw
    d = smin(d, ell(X, Y, Z, (0, -84, -24), (18 * jaw, 13, 13)), 12)            # chin
    d = smin(d, ell(X, Y, Z, (0, -50, -30), (27, 28, 25)), 14)                  # muzzle
    # nose: bridge to tip, plus alae
    d = smin(d, cap(X, Y, Z, (0, 2, -9), (0, -36, 5 + p["nose"]), 5.5, 8.5), 7)
    for s in (-1, 1):
        d = smin(d, ell(X, Y, Z, (s * 11, -39, -6), (8, 6.5, 8)), 5)
    # lips
    d = smin(d, ell(X, Y, Z, (0, -53, -9), (18, 5, 8)), 4)
    d = smin(d, ell(X, Y, Z, (0, -62, -11), (15.5, 5.5, 8)), 4)
    d = smax(d, -ell(X, Y, Z, (0, -57.6, -1), (16, 1.1, 8)), 1.5)              # mouth line
    # eye sockets and closed lids
    for s in (-1, 1):
        d = smax(d, -ell(X, Y, Z, (s * 32, 1, -4), (19, 11, 12)), 6)
        d = smin(d, ell(X, Y, Z, (s * 32, 0, -27), (13, 12, 12)), 3)
    # ears (the glasses arms rest on their tops)
    for s in (-1, 1):
        e = ell(X, Y, Z, (s * 64 * w, -21, -116), (7, 27, 16))
        e = smax(e, -ell(X, Y, Z, (s * 69 * w, -19, -114), (4, 19, 10)), 3)
        d = smin(d, e, 4)
    # neck and shoulders, cut flat like a sculpture bust
    neck = cap(X, Y, Z, (0, -60, -112), (0, -190, -96), 47 * p["neck"], 55 * p["neck"])
    neck = smin(neck, ell(X, Y, Z, (0, -190, -108), (105 * p["shoulders"], 34, 62)), 34)        # trapezius
    neck = smin(neck, ell(X, Y, Z, (0, -238, -100), (190 * p["shoulders"], 58, 92)), 40)       # shoulders
    neck = smin(neck, ell(X, Y, Z, (0, -276, -78), (150 * p["shoulders"], 70, 84)), 40)        # chest
    d = smin(d, neck, 10)
    d = smax(d, -(Y + 310), 4)
    return d


def hair(X, Y, Z, skin, style):
    shell = skin - style["thick"]
    # keep only above a hairline that runs high at the forehead and low at the nape
    line = Y - (style["front"] + 0.42 * (Z + 30) + 0.0035 * X * X - np.minimum(0, Z + 150) * 0.6)
    h = smax(shell, -line, 10)
    h = smax(h, -(Y - style["min_y"]), 6)
    # keep hair off the face and ears
    for s in (-1, 1):
        h = smax(h, -ell(X, Y, Z, (s * 66, -21, -116), (14, 36, 24)), 4)
    if style.get("bun"):
        h = smin(h, ell(X, Y, Z, (0, 96, -170), (30, 28, 30)), 12)
    if style.get("volume"):
        h = smin(h, ell(X, Y, Z, (0, 70, -110), (74, 78, 104)), 20)
        h = smax(h, -line, 6)
    return h


def write(path, verts, norms, faces):
    with open(path, "wb") as f:
        f.write(struct.pack("<II", len(verts), faces.size))
        f.write(verts.astype("<f4").tobytes())
        f.write(norms.astype("<f4").tobytes())
        f.write(faces.astype("<u4").tobytes())
    print(path, len(verts), "verts", len(faces), "tris")


def mesh(field, axes):
    xs, ys, zs = axes
    v, f, n, _ = measure.marching_cubes(field, 0.0, spacing=(RES, RES, RES), step_size=1,
                                        gradient_direction="ascent")
    v += np.array([xs[0], ys[0], zs[0]], np.float32)
    # with "ascent" the normals point towards increasing distance, i.e. outwards
    return v, n, f


MODELS = {
    "ava": dict(width=0.97, jaw=0.92, nose=0, neck=0.88, shoulders=0.9,
                hair=dict(thick=4, front=60, min_y=-60, bun=True)),
    "kai": dict(width=1.02, jaw=1.06, nose=2, neck=1.0, shoulders=1.04,
                hair=dict(thick=3.5, front=54, min_y=-36)),
    "noor": dict(width=0.98, jaw=0.96, nose=1, neck=0.9, shoulders=0.95,
                 hair=dict(thick=6, front=62, min_y=-120, volume=True)),
}

if __name__ == "__main__":
    names = sys.argv[1:] or list(MODELS)
    axes, X, Y, Z = grid()
    for name in names:
        p = MODELS[name]
        skin = head(X, Y, Z, p)
        write(f"bust-{name}-skin.bin", *mesh(skin, axes))
        hr = hair(X, Y, Z, skin, p["hair"])
        write(f"bust-{name}-hair.bin", *mesh(hr, axes))
