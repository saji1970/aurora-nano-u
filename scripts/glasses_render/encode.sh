#!/bin/sh
# Encodes frames/<clip>/ into site/assets/video/<clip>.{mp4,webm}
set -e
out=../../site/assets/video; mkdir -p "$out"
for clip in turntable explode; do
  ffmpeg -y -loglevel error -framerate 30 -i frames/$clip/%04d.png -c:v libx264 -preset slow -crf 24 -pix_fmt yuv420p -movflags +faststart -an "$out/$clip.mp4"
  ffmpeg -y -loglevel error -framerate 30 -i frames/$clip/%04d.png -c:v libvpx-vp9 -b:v 0 -crf 36 -row-mt 1 -an "$out/$clip.webm"
done
ls -la "$out"
