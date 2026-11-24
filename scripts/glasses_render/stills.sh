#!/bin/sh
# Renders the showcase-site stills into stills/ (needs the http-server on :8765 and bust-*.bin from make_bust.py)
set -e
for c in obsidian:clear glacier:clear havana:amber midnight:sun sage:clear blush:rose; do
  id=${c%%:*}; lens=${c##*:}
  node shot2.js stills/colour-$id.png "mode=assembled&clean&w=2000&h=1250&color=$id&lens=$lens"
done
node shot2.js stills/model-1.png "mode=worn&model=ava&w=1400&h=1600&view=three-quarter&skin=e8e4dc&hair=e8e4dc&color=havana&lens=amber&bg=f6efe6,eadfce,d5c4ad"
node shot2.js stills/model-2.png "mode=worn&model=kai&w=1600&h=1100&view=profile&skin=3c3d42&hair=3c3d42&color=glacier&bg=dfe6ee,c9d3df,a9b6c6"
node shot2.js stills/model-3.png "mode=worn&model=noor&w=1600&h=1100&view=low&skin=b9775a&hair=b9775a&color=midnight&lens=sun&bg=f4e3d6,e6c9b5,c9a088"
node shot2.js stills/front.png "mode=front&clean&w=2000&h=1100&bg=34363c,1d1f23,0d0e10"
