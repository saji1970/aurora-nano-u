// Usage: node shot2.js <out.png> "<query string>"
const { chromium } = require('playwright');
(async () => {
  const [out, q] = process.argv.slice(2);
  const qs = new URLSearchParams(q); const w = +qs.get('w') || 2400, h = +qs.get('h') || 1500;
  const b = await chromium.launch({ args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
  const p = await b.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  p.on('console', m => console.log('console:', m.text()));
  p.on('pageerror', e => console.log('ERR', e.message));
  await p.goto(`http://localhost:8765/glasses.html?${q}`);
  await p.waitForFunction(() => window.RENDER_DONE === true, null, { timeout: 600000 });
  await p.screenshot({ path: out, timeout: 0 });
  await b.close();
})();
