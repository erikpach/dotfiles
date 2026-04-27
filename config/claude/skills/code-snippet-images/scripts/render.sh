#!/usr/bin/env bash
# Render an HTML file to a high-resolution PNG using Chrome headless.
# Usage: render.sh <input.html> <output.png> [width] [height] [scale]
#
# Defaults: 1200x675 at 2x scale → produces 2400x1350 PNG
set -euo pipefail

INPUT="${1:?Usage: render.sh <input.html> <output.png> [width] [height] [scale]}"
OUTPUT="${2:?Usage: render.sh <input.html> <output.png> [width] [height] [scale]}"
WIDTH="${3:-1200}"
HEIGHT="${4:-675}"
SCALE="${5:-2}"

# Resolve absolute path for file:// URL
INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"

google-chrome \
  --headless \
  --no-sandbox \
  --disable-gpu \
  --force-device-scale-factor="$SCALE" \
  --window-size="${WIDTH},${HEIGHT}" \
  --screenshot="$OUTPUT" \
  "file://${INPUT_ABS}" \
  2>/dev/null

echo "Rendered: $OUTPUT ($(identify -format '%wx%h' "$OUTPUT" 2>/dev/null || file "$OUTPUT" | grep -oP '\d+ x \d+'))"
