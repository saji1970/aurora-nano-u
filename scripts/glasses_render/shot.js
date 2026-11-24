const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ args: ['--use-angle=swiftshader','--enable-unsafe-swiftshader','--ignore-gpu-blocklist'] });
  const p = await b.newPage({ viewport: { width: 2400, height: 1500 }, deviceScaleFactor: 1 });
  p.on('console', m => console.log('console:', m.text()));
  p.on('pageerror', e => console.log('ERR', e.message));
  for (const mode of process.argv.slice(2)) {
    await p.goto(`http://localhost:8765/glasses.html?mode=${mode}`);
    await p.waitForFunction(() => window.RENDER_DONE === true, null, { timeout: 300000 });
    await p.screenshot({ path: `out-${mode}.png` });
    console.log('done', mode);
  }
  await b.close();
})();
