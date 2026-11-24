# Glasses concept renders

`glasses.html` builds a Three.js model of the Aurora glasses from the sizes in
[docs/glasses-packaging.md](../../docs/glasses-packaging.md). Query parameters
pick what it draws:

| Parameter | Values |
| --- | --- |
| `mode` | `assembled`, `exploded`, `front` (labelled doc renders), `worn` (on a sculpted bust), `anim` (animation, driven by `anim.js`) |
| `color` | `obsidian`, `glacier`, `havana`, `midnight`, `sage`, `blush` |
| `lens` | `clear`, `sun`, `amber`, `blue`, `rose` |
| `w`, `h` | image size in pixels (default 2400 × 1500) |
| `clean` | leave out the title and labels |
| `bg` | background gradient, up to three hex colours without `#`, e.g. `bg=34363c,1d1f23,0d0e10` |
| `model`, `view`, `skin`, `hair` | for `mode=worn`: bust (`ava`, `kai`, `noor`), camera (`three-quarter`, `front`, `profile`, `close`, `low`), and colours |

```sh
cd scripts/glasses_render
npm install three@0.170.0 playwright
pip install numpy scikit-image
npx http-server -p 8765 -s . &

# documentation renders (docs/images/glasses-render-*.png)
node shot.js assembled exploded front

# sculpted busts for the on-model shots (writes bust-*.bin, not committed)
python3 make_bust.py

# showcase-site stills (stills/*.png)
./stills.sh

# animation frames, then encode
node anim.js turntable 1600 900 "bg=34363c,1d1f23,0d0e10&oy=70"
node anim.js explode 1600 900 "bg=34363c,1d1f23,0d0e10"
./encode.sh
```

The busts in `make_bust.py` are signed-distance sculptures (blended ellipsoids
and capsules meshed with marching cubes). They are deliberately abstract, like
a shop display head, so they depict no real person.

Part sizes and positions are near the top of `glasses.html` (lens, arm and
board dimensions in mm) so the model can be updated as the CAD design firms up.
