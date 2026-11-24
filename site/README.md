# Aurora showcase site

A single static page that tells the Aurora glasses story: the concept, the six
colour finishes, the glasses on sculpted busts, an exploded-view film, the
design (block diagram and packaging), the camera, Android and the launch apps, the roadmap, the cost estimate and the
funding requirement. No build step: open `index.html` or serve the folder.

```sh
cd site && npx serve .      # or: python3 -m http.server
```

## Deploying

The folder is self-contained (about 8 MB including the two videos), so any
static host works.

- **GitHub Pages:** in the repository's Settings > Pages, set the source to
  "GitHub Actions" once. After that, every change to `site/` merged into
  `main` publishes automatically (`.github/workflows/pages.yml`), and the
  workflow can also be run by hand from the Actions tab. The site lives at
  https://saji1970.github.io/aurora-nano-u/.
- **Netlify or Cloudflare Pages:** drag the `site` folder onto the dashboard,
  or connect the repository with the publish directory set to `site` and no
  build command.
- **Vercel:** import the repository and set the root directory to `site`.

## Where the content comes from

| Part of the page | Source |
| --- | --- |
| Specs, packaging, block diagram | `docs/glasses-board.md`, `docs/glasses-packaging.md` |
| Camera section | `docs/glasses-camera.md` |
| Android and apps section | `docs/glasses-software-platform.md` |
| Cost tiles and bill of materials | `docs/glasses-cost-and-sourcing.md` |
| Funding stages, use of funds, unit economics, lean path, risks | `docs/glasses-funding-requirement.md` |
| Colour, on-model and hero images, both videos | rendered by `scripts/glasses_render/` (see its README) |

All figures are planning estimates from those documents, not quotes. Update the
page when the documents change.

## Images

Every product image and both videos are 3D concept renders. The on-model shots
use abstract sculpted display busts rather than people, so there is no model
release or likeness to clear. Swap in real photography of prototypes once it
exists by replacing the files in `assets/img/` with the same names.
