#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CHROME_BIN=${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}

if [ ! -x "$CHROME_BIN" ]; then
  CHROME_BIN=$(command -v google-chrome || command -v chromium || true)
fi

if [ -z "$CHROME_BIN" ] || [ ! -x "$CHROME_BIN" ]; then
  printf 'Google Chrome or Chromium is required. Set CHROME_BIN explicitly.\n' >&2
  exit 1
fi

command -v cwebp >/dev/null || {
  printf 'cwebp is required.\n' >&2
  exit 1
}

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/aohs-profile-assets.XXXXXX")
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$TEMP_DIR/source" "$ROOT_DIR/assets/brand" "$ROOT_DIR/assets/projects"
cp "$ROOT_DIR/scripts/profile-assets.html" "$TEMP_DIR/profile-assets.html"

fetch() {
  url=$1
  output=$2
  curl --fail --location --retry 3 --connect-timeout 10 --max-time 60 --silent --show-error "$url" --output "$output"
}

fetch 'https://raw.githubusercontent.com/qingzhizhu517-rgb/blog-t1/main/public/Aohs.jpg' "$TEMP_DIR/source/aohs.jpg"
fetch 'https://raw.githubusercontent.com/qingzhizhu517-rgb/wfit--workload/main/else/end.png' "$TEMP_DIR/source/wfit.png"
fetch 'https://raw.githubusercontent.com/qingzhizhu517-rgb/sjg/master/admin-frontend/src/assets/hero.png' "$TEMP_DIR/source/sjg.png"
fetch 'https://github.com/user-attachments/assets/6ff59d72-0777-49c1-b936-965e4fdc4a5e' "$TEMP_DIR/source/pet.png"

render() {
  asset_name=$1
  width=$2
  height=$3
  destination=$4
  png_output="$TEMP_DIR/$asset_name.png"

  "$CHROME_BIN" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --allow-file-access-from-files \
    --force-device-scale-factor=1 \
    --run-all-compositor-stages-before-draw \
    --virtual-time-budget=7000 \
    --window-size="$width,$height" \
    --screenshot="$png_output" \
    "file://$TEMP_DIR/profile-assets.html?asset=$asset_name" \
    >/dev/null 2>&1

  cwebp -quiet -q 88 -m 6 "$png_output" -o "$ROOT_DIR/$destination"
  printf 'Rendered %s\n' "$destination"
}

render header 1600 520 assets/brand/aohs-header.webp
render wfit 1600 720 assets/projects/wfit-system.webp
render aohs 1600 720 assets/projects/aohs-space.webp
render sjg 1600 720 assets/projects/sjg-content-map.webp
render pet 1600 720 assets/projects/pet-market-ai.webp
