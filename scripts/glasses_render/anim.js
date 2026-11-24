// Renders the turntable and explode animations to frames/<clip>/NNNN.png.
// Usage: node anim.js <clip> <w> <h> "<extra query>"   clip = turntable | explode
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const [clip, w, h, extra = ''] = process.argv.slice(2);
  const W = +w, H = +h, FPS = 30;
  const dir = `frames/${clip}`; fs.mkdirSync(dir, { recursive: true });
  const b = await chromium.launch({ args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
  const p = await b.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
  p.on('pageerror', e => console.log('ERR', e.message));
  await p.goto(`http://localhost:8765/glasses.html?mode=anim&w=${W}&h=${H}&${extra}`);
  await p.waitForFunction(() => window.RENDER_DONE === true, null, { timeout: 600000 });
  const keys = [];
  if (clip === 'turntable') {
    const N = 10 * FPS;                       // one slow 360 degree turn
    for (let i = 0; i < N; i++) keys.push([0, -i / N * Math.PI * 2]);
  } else {
    // hold, explode while turning, hold and turn, reassemble
    const seq = [[0.7, 0, 0, 0, 0.15], [3.0, 0, 1, 0.15, 0.75], [3.0, 1, 1, 0.75, 1.35], [2.6, 1, 0, 1.35, 1.9], [0.7, 0, 0, 1.9, 2.0]];
    for (const [dur, t0, t1, y0, y1] of seq) {
      const n = Math.round(dur * FPS);
      for (let i = 0; i < n; i++) { const u = i / n; keys.push([t0 + (t1 - t0) * u, -(y0 + (y1 - y0) * u)]); }
    }
  }
  for (let i = 0; i < keys.length; i++) {
    await p.evaluate(([t, y]) => window.frame(t, y), keys[i]);
    await p.screenshot({ path: `${dir}/${String(i).padStart(4, '0')}.png` });
    if (i % 30 === 0) console.log(clip, i, '/', keys.length);
  }
  await b.close();
})();
