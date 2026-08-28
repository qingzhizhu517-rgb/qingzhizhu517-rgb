#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

FAILURES=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  FAILURES=$((FAILURES + 1))
}

require_file() {
  if [ -s "$1" ]; then
    pass "$1 exists"
  else
    fail "$1 is missing or empty"
  fi
}

require_absent() {
  if [ -e "$1" ]; then
    fail "$1 should have been removed"
  else
    pass "$1 is absent"
  fi
}

require_text() {
  file_path=$1
  expected=$2
  if rg -Fq -- "$expected" "$file_path"; then
    pass "$file_path contains $expected"
  else
    fail "$file_path is missing $expected"
  fi
}

forbid_text() {
  file_path=$1
  forbidden=$2
  if rg -Fq -- "$forbidden" "$file_path"; then
    fail "$file_path still contains $forbidden"
  else
    pass "$file_path does not contain $forbidden"
  fi
}

check_repository() {
  require_file README.md
  require_file LICENSE
  require_file .github/workflows/grid-snake.yml
  require_file .github/workflows/profile-3d.yml
  require_file profile-3d-contrib/profile-night-green.svg

  legacy_paths=(
    .DS_Store
    .github/workflows/Metrics.yml
    CODE_OF_CONDUCT.md
    CONTRIBUTING.md
    DEPLOYMENT.md
    IMAGE-FIX-GUIDE.md
    QUICK-START.md
    RETRY-GUIDE.md
    SOLUTION.md
    TROUBLESHOOTING.md
    github-metrics.svg
    simple_interest.sh
    test-urls.sh
    qingzhizhu517-rgb
  )

  for path in "${legacy_paths[@]}"; do
    require_absent "$path"
  done

  extra_3d=$(find profile-3d-contrib -type f ! -name profile-night-green.svg -print -quit)
  if [ -n "$extra_3d" ]; then
    fail "unexpected 3D contribution variant: $extra_3d"
  else
    pass "only profile-night-green.svg is retained"
  fi

  if rg -Fxq '.superpowers/' .gitignore; then
    pass ".superpowers/ is ignored"
  else
    fail ".superpowers/ is not ignored"
  fi
}

check_assets() {
  assets=(
    assets/brand/aohs-header.webp
    assets/projects/wfit-system.webp
    assets/projects/aohs-space.webp
    assets/projects/sjg-content-map.webp
    assets/projects/pet-market-ai.webp
  )

  for asset in "${assets[@]}"; do
    require_file "$asset"
    if [ -s "$asset" ]; then
      mime=$(file -b --mime-type "$asset")
      [ "$mime" = image/webp ] || fail "$asset has MIME type $mime instead of image/webp"
      bytes=$(wc -c < "$asset" | tr -d ' ')
      [ "$bytes" -le 900000 ] || fail "$asset is larger than 900 KB"
    fi
  done

  xmllint --noout profile-3d-contrib/profile-night-green.svg >/dev/null
  pass "profile-night-green.svg is valid XML"
}

check_readme() {
  required_strings=(
    'Aohs'
    '@qingzhizhu517-rgb'
    'Engineering systems. Designing experiences.'
    '把复杂需求做成真正可用的产品。'
    'Java / 全栈产品开发 · AI 应用集成'
    'WFIT Workload'
    'Aohs Space'
    '黄河文学景观'
    'Pet Market'
    'Spring AI · RAG · LLM 应用架构'
    'Contribution Lab'
    'qingzhizhu517@gmail.com'
  )

  for text in "${required_strings[@]}"; do
    require_text README.md "$text"
  done

  forbidden_strings=(
    'readme-typing-svg.herokuapp.com'
    'github-readme-stats.vercel.app'
    'github-readme-streak-stats.herokuapp.com'
    'github-profile-trophy.vercel.app'
    'github-readme-activity-graph.vercel.app'
    'komarev.com'
    'api.star-history.com'
    'PyTorch'
    'TensorFlow'
    'LangChain'
  )

  for text in "${forbidden_strings[@]}"; do
    forbid_text README.md "$text"
  done

  image_refs=(
    './assets/brand/aohs-header.webp'
    './assets/projects/wfit-system.webp'
    './assets/projects/aohs-space.webp'
    './assets/projects/sjg-content-map.webp'
    './assets/projects/pet-market-ai.webp'
    './profile-3d-contrib/profile-night-green.svg'
  )

  for ref in "${image_refs[@]}"; do
    require_text README.md "$ref"
  done

  location_count=$( (rg -oF 'Shandong, China' README.md || true) | wc -l | tr -d ' ')
  [ "$location_count" = 1 ] || fail "Shandong, China must appear exactly once"
}

check_workflows() {
  require_absent .github/workflows/Metrics.yml

  require_text .github/workflows/grid-snake.yml 'Platane/snk@d8f6715049803e982ee5ff501b6b9b7d5deeb09b'
  require_text .github/workflows/grid-snake.yml 'peaceiris/actions-gh-pages@84c30a85c19949d7eee79c4ff27748b70285e453'
  require_text .github/workflows/profile-3d.yml 'actions/checkout@11d5960a326750d5838078e36cf38b85af677262'
  require_text .github/workflows/profile-3d.yml 'yoshi389111/github-profile-3d-contrib@69fe3757279590c632c16189bb91445b51dc985f'
  require_text .github/workflows/profile-3d.yml '41898282+github-actions[bot]@users.noreply.github.com'

  forbid_text .github/workflows/grid-snake.yml '@latest'
  forbid_text .github/workflows/profile-3d.yml '@latest'
  forbid_text .github/workflows/profile-3d.yml 'ACTIONS_TOKEN'
  forbid_text .github/workflows/profile-3d.yml 'your-email@example.com'

  if rg -n '^  push:' .github/workflows/grid-snake.yml >/dev/null; then
    fail "grid-snake.yml should not run on every push"
  else
    pass "grid-snake.yml has no push trigger"
  fi
}

check_links() {
  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/aohs-profile-links.XXXXXX")
  trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

  links=(
    'https://github.com/qingzhizhu517-rgb|text/html'
    'https://aohs.top/|text/html'
    'https://github.com/qingzhizhu517-rgb/wfit--workload|text/html'
    'https://github.com/qingzhizhu517-rgb/blog-t1|text/html'
    'https://github.com/qingzhizhu517-rgb/sjg|text/html'
    'https://github.com/qingzhizhu517-rgb/pet-market|text/html'
    'https://raw.githubusercontent.com/qingzhizhu517-rgb/qingzhizhu517-rgb/output/github-contribution-grid-snake.svg|image/svg+xml'
    'https://raw.githubusercontent.com/qingzhizhu517-rgb/qingzhizhu517-rgb/output/github-contribution-grid-snake-dark.svg|image/svg+xml'
  )

  index=0
  for entry in "${links[@]}"; do
    url=${entry%%|*}
    expected_type=${entry#*|}
    headers="$temp_dir/headers-$index"
    body="$temp_dir/body-$index"
    status=$(curl --silent --show-error --location --retry 2 --connect-timeout 10 --max-time 30 --dump-header "$headers" --output "$body" --write-out '%{http_code}' "$url")
    if [ "$status" -ge 200 ] && [ "$status" -lt 400 ]; then
      pass "$url returned $status"
    else
      fail "$url returned $status"
    fi
    content_type=$(tr '[:upper:]' '[:lower:]' < "$headers" | awk '/^content-type:/{gsub("\\r", "", $2); print $2}' | tail -1)
    case "$content_type" in
      "$expected_type"*) pass "$url returned $content_type" ;;
      *) fail "$url returned $content_type instead of $expected_type" ;;
    esac
    index=$((index + 1))
  done
}

mode=${1:-all}
case "$mode" in
  repository) check_repository ;;
  assets) check_assets ;;
  readme) check_readme ;;
  workflows) check_workflows ;;
  links) check_links ;;
  all)
    check_repository
    check_assets
    check_readme
    check_workflows
    ;;
  *)
    printf 'Usage: %s [repository|assets|readme|workflows|links|all]\n' "$0" >&2
    exit 2
    ;;
esac

if [ "$FAILURES" -ne 0 ]; then
  printf '%s validation failure(s)\n' "$FAILURES" >&2
  exit 1
fi
