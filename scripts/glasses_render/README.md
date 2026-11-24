# Glasses concept renders

`glasses.html` builds a Three.js model of the Aurora glasses from the sizes in
[docs/glasses-packaging.md](../../docs/glasses-packaging.md) and draws one of
three views, picked with `?mode=assembled`, `?mode=exploded` or `?mode=front`.
`shot.js` opens each view in headless Chromium and saves a 2400 × 1500 PNG.

```sh
cd scripts/glasses_render
npm install three@0.170.0 playwright
npx http-server -p 8765 -s . &
node shot.js assembled exploded front
# writes out-<mode>.png; copy them to docs/images/glasses-render-<mode>.png
```

Part sizes and positions are near the top of `glasses.html` (lens, arm and
board dimensions in mm) so the model can be updated as the CAD design firms up.
