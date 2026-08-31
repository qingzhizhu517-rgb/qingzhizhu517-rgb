#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
lock_key=$(printf '%s' "$ROOT_DIR" | cksum | awk '{print $1}')
LOCK_DIR="${TMPDIR:-/tmp}/aohs-profile-assets-$lock_key.lock"
LOCK_HELD=0
TEMP_DIR=
PUBLISHING=0
PENDING_SIGNAL=0
PUBLISH_TEMP_HEADER=
PUBLISH_TEMP_WFIT=
PUBLISH_TEMP_AOHS=
PUBLISH_TEMP_SJG=
PUBLISH_TEMP_PET=

cleanup() {
  [ -n "$PUBLISH_TEMP_HEADER" ] && rm -f "$PUBLISH_TEMP_HEADER"
  [ -n "$PUBLISH_TEMP_WFIT" ] && rm -f "$PUBLISH_TEMP_WFIT"
  [ -n "$PUBLISH_TEMP_AOHS" ] && rm -f "$PUBLISH_TEMP_AOHS"
  [ -n "$PUBLISH_TEMP_SJG" ] && rm -f "$PUBLISH_TEMP_SJG"
  [ -n "$PUBLISH_TEMP_PET" ] && rm -f "$PUBLISH_TEMP_PET"

  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi

  if [ "$LOCK_HELD" -eq 1 ]; then
    rmdir "$LOCK_DIR" >/dev/null 2>&1 || true
    LOCK_HELD=0
  fi
}

handle_signal() {
  signal_code=$1
  if [ "$PUBLISHING" -eq 1 ]; then
    PENDING_SIGNAL=$signal_code
    return
  fi
  exit "$signal_code"
}

if ! mkdir "$LOCK_DIR"; then
  printf 'Profile asset rendering is already running (lock: %s).\n' "$LOCK_DIR" >&2
  exit 1
fi
LOCK_HELD=1

trap cleanup EXIT
trap 'handle_signal 129' HUP
trap 'handle_signal 130' INT
trap 'handle_signal 143' TERM

CHROME_BIN=${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}

if [ ! -x "$CHROME_BIN" ]; then
  CHROME_BIN=$(command -v google-chrome || command -v chromium || true)
fi

if [ -z "$CHROME_BIN" ] || [ ! -x "$CHROME_BIN" ]; then
  printf 'Google Chrome or Chromium is required. Set CHROME_BIN explicitly.\n' >&2
  exit 1
fi

for required_command in curl cwebp file shasum sips; do
  if ! command -v "$required_command" >/dev/null; then
    printf '%s is required.\n' "$required_command" >&2
    exit 1
  fi
done

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/aohs-profile-assets.XXXXXX")
mkdir -p "$TEMP_DIR/source" "$TEMP_DIR/rendered" "$TEMP_DIR/logs"
cp "$ROOT_DIR/scripts/profile-assets.html" "$TEMP_DIR/profile-assets.html"

fetch() {
  url=$1
  output=$2
  expected_sha=$3
  expected_mime=$4

  if ! curl --fail --location --retry 3 --connect-timeout 10 --max-time 60 --silent --show-error "$url" --output "$output"; then
    printf 'Failed to fetch source asset: %s\n' "$url" >&2
    exit 1
  fi

  actual_sha=$(shasum -a 256 "$output" | awk '{print $1}')
  if [ "$actual_sha" != "$expected_sha" ]; then
    printf 'SHA-256 mismatch for %s: expected %s, got %s.\n' "$url" "$expected_sha" "$actual_sha" >&2
    exit 1
  fi

  actual_mime=$(file -b --mime-type "$output")
  if [ "$actual_mime" != "$expected_mime" ]; then
    printf 'MIME mismatch for %s: expected %s, got %s.\n' "$url" "$expected_mime" "$actual_mime" >&2
    exit 1
  fi

  if ! dimensions=$(sips -g pixelWidth -g pixelHeight "$output" 2>&1); then
    printf 'Source image could not be decoded by sips: %s\n' "$url" >&2
    printf '%s\n' "$dimensions" >&2
    exit 1
  fi

  pixel_width=$(printf '%s\n' "$dimensions" | awk '/pixelWidth:/ {print $2; exit}')
  pixel_height=$(printf '%s\n' "$dimensions" | awk '/pixelHeight:/ {print $2; exit}')
  case "$pixel_width" in
    ''|*[!0-9]*)
      printf 'Source image has an invalid pixel width: %s\n' "$url" >&2
      exit 1
      ;;
  esac
  case "$pixel_height" in
    ''|*[!0-9]*)
      printf 'Source image has an invalid pixel height: %s\n' "$url" >&2
      exit 1
      ;;
  esac
}

fetch \
  'https://raw.githubusercontent.com/qingzhizhu517-rgb/blog-t1/83c8ebd240d342153e8cf77d59c1ac1ad5f53e64/public/Aohs.jpg' \
  "$TEMP_DIR/source/aohs.jpg" \
  'd1e69c70f328395ab4350417ea4327f1ed255b4310a9239de8c0d0ef2700e483' \
  'image/jpeg'
fetch \
  'https://raw.githubusercontent.com/qingzhizhu517-rgb/wfit--workload/cad2e0a395c2ecf8e5a960344e30d5ec5d218504/else/end.png' \
  "$TEMP_DIR/source/wfit.png" \
  '45fbe1acd0c541ee6d6204406b92a40e32fe40a110815f4b7185379abafba812' \
  'image/png'
fetch \
  'https://raw.githubusercontent.com/qingzhizhu517-rgb/sjg/d81599e05476b6a223cd5f663fcec2228262ca3a/admin-frontend/src/assets/hero.png' \
  "$TEMP_DIR/source/sjg.png" \
  '881ffbcaafc212e49addad08846a5b82761355fa20624253af3477ba33262c5c' \
  'image/png'
fetch \
  'https://github.com/user-attachments/assets/6ff59d72-0777-49c1-b936-965e4fdc4a5e' \
  "$TEMP_DIR/source/pet.png" \
  '251669049f49e49d6c9d8914b10345974c6d0eac138cd359dce43fd564690c72' \
  'image/jpeg'

require_source_reference() {
  source_path=$1
  if ! grep -Fq "src=\"$source_path\"" "$TEMP_DIR/profile-assets.html"; then
    printf 'Profile asset HTML does not reference validated source: %s\n' "$source_path" >&2
    exit 1
  fi
}

require_source_reference 'source/aohs.jpg'
require_source_reference 'source/wfit.png'
require_source_reference 'source/sjg.png'
require_source_reference 'source/pet.png'

validate_png() {
  output_path=$1
  expected_width=$2
  expected_height=$3

  if [ ! -s "$output_path" ]; then
    printf 'Chrome PNG is missing or empty: %s\n' "$output_path" >&2
    exit 1
  fi

  output_mime=$(file -b --mime-type "$output_path")
  if [ "$output_mime" != 'image/png' ]; then
    printf 'Chrome output has MIME %s instead of image/png: %s\n' "$output_mime" "$output_path" >&2
    exit 1
  fi

  if ! output_dimensions=$(sips -g pixelWidth -g pixelHeight "$output_path" 2>&1); then
    printf 'Chrome PNG could not be decoded by sips: %s\n' "$output_path" >&2
    printf '%s\n' "$output_dimensions" >&2
    exit 1
  fi

  output_width=$(printf '%s\n' "$output_dimensions" | awk '/pixelWidth:/ {print $2; exit}')
  output_height=$(printf '%s\n' "$output_dimensions" | awk '/pixelHeight:/ {print $2; exit}')
  if [ "$output_width" != "$expected_width" ] || [ "$output_height" != "$expected_height" ]; then
    printf 'Chrome PNG has dimensions %sx%s instead of %sx%s: %s\n' \
      "$output_width" "$output_height" "$expected_width" "$expected_height" "$output_path" >&2
    exit 1
  fi
}

validate_output() {
  output_path=$1
  expected_width=$2
  expected_height=$3

  if [ ! -s "$output_path" ]; then
    printf 'Rendered output is missing or empty: %s\n' "$output_path" >&2
    exit 1
  fi

  output_mime=$(file -b --mime-type "$output_path")
  if [ "$output_mime" != 'image/webp' ]; then
    printf 'Rendered output has MIME %s instead of image/webp: %s\n' "$output_mime" "$output_path" >&2
    exit 1
  fi

  output_bytes=$(wc -c < "$output_path" | tr -d '[:space:]')
  if [ "$output_bytes" -gt 900000 ]; then
    printf 'Rendered output exceeds 900000 bytes: %s (%s bytes).\n' "$output_path" "$output_bytes" >&2
    exit 1
  fi

  if ! output_dimensions=$(sips -g pixelWidth -g pixelHeight "$output_path" 2>&1); then
    printf 'Rendered output could not be decoded by sips: %s\n' "$output_path" >&2
    printf '%s\n' "$output_dimensions" >&2
    exit 1
  fi

  output_width=$(printf '%s\n' "$output_dimensions" | awk '/pixelWidth:/ {print $2; exit}')
  output_height=$(printf '%s\n' "$output_dimensions" | awk '/pixelHeight:/ {print $2; exit}')
  if [ "$output_width" != "$expected_width" ] || [ "$output_height" != "$expected_height" ]; then
    printf 'Rendered output has dimensions %sx%s instead of %sx%s: %s\n' \
      "$output_width" "$output_height" "$expected_width" "$expected_height" "$output_path" >&2
    exit 1
  fi
}

render() {
  asset_name=$1
  width=$2
  height=$3
  destination=$4
  expected_sha=$5
  png_output="$TEMP_DIR/rendered/$asset_name.png"
  webp_output="$TEMP_DIR/rendered/$(basename "$destination")"
  chrome_log="$TEMP_DIR/logs/$asset_name.chrome.log"
  cwebp_log="$TEMP_DIR/logs/$asset_name.cwebp.log"
  attempt=1
  while [ "$attempt" -le 5 ]; do
    if ! "$CHROME_BIN" \
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
      >/dev/null 2>"$chrome_log"; then
      printf 'Chrome screenshot failed for asset %s.\n' "$asset_name" >&2
      sed -n '1,120p' "$chrome_log" >&2
      exit 1
    fi

    validate_png "$png_output" "$width" "$height"

    if ! cwebp -quiet -q 88 -m 6 "$png_output" -o "$webp_output" 2>"$cwebp_log"; then
      printf 'cwebp failed for asset %s.\n' "$asset_name" >&2
      sed -n '1,120p' "$cwebp_log" >&2
      exit 1
    fi

    validate_output "$webp_output" "$width" "$height"
    actual_sha=$(shasum -a 256 "$webp_output" | awk '{print $1}')
    if [ "$actual_sha" = "$expected_sha" ]; then
      return
    fi

    attempt=$((attempt + 1))
  done

  printf 'Rendered asset hash mismatch for %s: expected %s, got %s.\n' \
    "$asset_name" "$expected_sha" "$actual_sha" >&2
  exit 1
}

render header 1600 520 assets/brand/aohs-header.webp 0452d478c9891c7a3bdf05e8d9ab359c25c8efcc477355075f0036d6c8a61e70
render wfit 1600 720 assets/projects/wfit-system.webp d007f293b7e942b646d17cb1fb21de0d5c5336bf1727397e38291a614b5b78f4
render aohs 1600 720 assets/projects/aohs-space.webp a1b6f6ff2c9e44d3be9b652f495a9e2f19918a4dc5ce9add394f91d58879cfb2
render sjg 1600 720 assets/projects/sjg-content-map.webp 9d93cdb3750cc8b0e55adacb712cc1e65690c5351c9bd09804bf168e38cc31b2
render pet 1600 720 assets/projects/pet-market-ai.webp ab8029d2a70932a9e46ed5308ef7bb219985f6156afe3458541e868b54853397

FINAL_HEADER="$ROOT_DIR/assets/brand/aohs-header.webp"
FINAL_WFIT="$ROOT_DIR/assets/projects/wfit-system.webp"
FINAL_AOHS="$ROOT_DIR/assets/projects/aohs-space.webp"
FINAL_SJG="$ROOT_DIR/assets/projects/sjg-content-map.webp"
FINAL_PET="$ROOT_DIR/assets/projects/pet-market-ai.webp"

mkdir -p "$ROOT_DIR/assets/brand" "$ROOT_DIR/assets/projects"

PUBLISH_TEMP_HEADER="$ROOT_DIR/assets/brand/.aohs-header.webp.tmp.$$"
PUBLISH_TEMP_WFIT="$ROOT_DIR/assets/projects/.wfit-system.webp.tmp.$$"
PUBLISH_TEMP_AOHS="$ROOT_DIR/assets/projects/.aohs-space.webp.tmp.$$"
PUBLISH_TEMP_SJG="$ROOT_DIR/assets/projects/.sjg-content-map.webp.tmp.$$"
PUBLISH_TEMP_PET="$ROOT_DIR/assets/projects/.pet-market-ai.webp.tmp.$$"

cp "$TEMP_DIR/rendered/aohs-header.webp" "$PUBLISH_TEMP_HEADER"
cp "$TEMP_DIR/rendered/wfit-system.webp" "$PUBLISH_TEMP_WFIT"
cp "$TEMP_DIR/rendered/aohs-space.webp" "$PUBLISH_TEMP_AOHS"
cp "$TEMP_DIR/rendered/sjg-content-map.webp" "$PUBLISH_TEMP_SJG"
cp "$TEMP_DIR/rendered/pet-market-ai.webp" "$PUBLISH_TEMP_PET"

PUBLISHING=1
mv "$PUBLISH_TEMP_HEADER" "$FINAL_HEADER"
mv "$PUBLISH_TEMP_WFIT" "$FINAL_WFIT"
mv "$PUBLISH_TEMP_AOHS" "$FINAL_AOHS"
mv "$PUBLISH_TEMP_SJG" "$FINAL_SJG"
mv "$PUBLISH_TEMP_PET" "$FINAL_PET"
PUBLISHING=0

PUBLISH_TEMP_HEADER=
PUBLISH_TEMP_WFIT=
PUBLISH_TEMP_AOHS=
PUBLISH_TEMP_SJG=
PUBLISH_TEMP_PET=

printf 'Rendered assets/brand/aohs-header.webp\n'
printf 'Rendered assets/projects/wfit-system.webp\n'
printf 'Rendered assets/projects/aohs-space.webp\n'
printf 'Rendered assets/projects/sjg-content-map.webp\n'
printf 'Rendered assets/projects/pet-market-ai.webp\n'

if [ "$PENDING_SIGNAL" -ne 0 ]; then
  exit "$PENDING_SIGNAL"
fi
