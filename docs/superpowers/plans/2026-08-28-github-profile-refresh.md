# Aohs GitHub Profile Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the unstable template-style GitHub Profile README with a content-rich, locally illustrated `Aohs Digital Lab` profile centered on four verifiable projects.

**Architecture:** Keep the repository as a build-free GitHub Profile README. Generate five deterministic WebP assets from a checked-in HTML artboard using local headless Chrome and `cwebp`, keep only the snake and one 3D contribution graph as dynamic content, and validate repository shape, README content, assets, workflows, and required links with one Bash script.

**Tech Stack:** GitHub-flavored Markdown, sanitized HTML, Bash 3-compatible scripts, headless Google Chrome, `cwebp`, GitHub Actions YAML, GitHub CLI, `curl`, `xmllint`.

---

## Preconditions

- Start from commit `10a3eee` or a descendant containing the approved design document.
- At execution time, create an isolated worktree with `superpowers:using-git-worktrees` unless the user explicitly asks to work directly on `main`.
- Do not push until Task 5 completes all local checks.
- Automated 3D graph commits can advance `origin/main`; fetch before each push and never discard those remote changes.
- Design source: `docs/superpowers/specs/2026-08-28-github-profile-refresh-design.md`.

## File Map

**Create**

- `scripts/check-profile.sh`: deterministic repository, asset, README, workflow, and link checks.
- `scripts/profile-assets.html`: single-purpose artboard for the brand header and four project visuals.
- `scripts/render-profile-assets.sh`: downloads source screenshots into a temporary directory and renders WebP outputs.
- `assets/brand/aohs-header.webp`: local brand header.
- `assets/projects/wfit-system.webp`: WFIT architecture and workflow visual.
- `assets/projects/aohs-space.webp`: real Aohs Space experience visual.
- `assets/projects/sjg-content-map.webp`: Yellow River literary landscape relationship visual.
- `assets/projects/pet-market-ai.webp`: Pet Market screenshot and AI fallback flow visual.

**Modify**

- `.gitignore`: ignore `.superpowers/` while retaining `.DS_Store` protection.
- `README.md`: replace the full template profile with the approved single-column project narrative.
- `.github/workflows/grid-snake.yml`: schedule-only snake generation with pinned actions and minimum permissions.
- `.github/workflows/profile-3d.yml`: pinned action, bot identity, single retained variant, no empty commits.

**Delete**

- `.DS_Store`
- `.github/workflows/Metrics.yml`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `DEPLOYMENT.md`
- `IMAGE-FIX-GUIDE.md`
- `QUICK-START.md`
- `RETRY-GUIDE.md`
- `SOLUTION.md`
- `TROUBLESHOOTING.md`
- `github-metrics.svg`
- `simple_interest.sh`
- `test-urls.sh`
- `qingzhizhu517-rgb/`
- Every file in `profile-3d-contrib/` except `profile-night-green.svg`

## Task 1: Establish Validation and Remove Legacy Scaffold

**Files:**

- Create: `scripts/check-profile.sh`
- Modify: `.gitignore`
- Delete: the legacy files listed in the File Map

- [ ] **Step 1: Create the complete profile validation script**

Create `scripts/check-profile.sh` with this exact content:

```bash
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
```

Make it executable:

```bash
chmod +x scripts/check-profile.sh
```

- [ ] **Step 2: Run the repository check and confirm the legacy scaffold fails**

Run:

```bash
./scripts/check-profile.sh repository
```

Expected: exit `1`, with failures for the nested `qingzhizhu517-rgb/` directory, old guides, Metrics workflow, extra 3D variants, and missing `.superpowers/` ignore rule.

- [ ] **Step 3: Add the visual-companion ignore rule**

Append this exact line under the temporary-files section of `.gitignore`:

```gitignore
.superpowers/
```

- [ ] **Step 4: Remove the approved legacy files using explicit Git paths**

Run:

```bash
git rm -r -- qingzhizhu517-rgb
git rm -- \
  .DS_Store \
  .github/workflows/Metrics.yml \
  CODE_OF_CONDUCT.md \
  CONTRIBUTING.md \
  DEPLOYMENT.md \
  IMAGE-FIX-GUIDE.md \
  QUICK-START.md \
  RETRY-GUIDE.md \
  SOLUTION.md \
  TROUBLESHOOTING.md \
  github-metrics.svg \
  simple_interest.sh \
  test-urls.sh \
  profile-3d-contrib/profile-gitblock.svg \
  profile-3d-contrib/profile-green-animate.svg \
  profile-3d-contrib/profile-green.svg \
  profile-3d-contrib/profile-night-rainbow.svg \
  profile-3d-contrib/profile-night-view.svg \
  profile-3d-contrib/profile-season-animate.svg \
  profile-3d-contrib/profile-season.svg \
  profile-3d-contrib/profile-south-season-animate.svg \
  profile-3d-contrib/profile-south-season.svg
```

- [ ] **Step 5: Run the repository check and confirm it passes**

Run:

```bash
bash -n scripts/check-profile.sh
./scripts/check-profile.sh repository
git diff --check
```

Expected: all repository checks print `PASS`; `git diff --check` prints nothing.

- [ ] **Step 6: Commit the repository cleanup**

```bash
git add .gitignore scripts/check-profile.sh
git commit -m "chore: remove legacy profile scaffold"
```

## Task 2: Generate the Brand and Project Visual Assets

**Files:**

- Create: `scripts/profile-assets.html`
- Create: `scripts/render-profile-assets.sh`
- Create: `assets/brand/aohs-header.webp`
- Create: `assets/projects/wfit-system.webp`
- Create: `assets/projects/aohs-space.webp`
- Create: `assets/projects/sjg-content-map.webp`
- Create: `assets/projects/pet-market-ai.webp`

- [ ] **Step 1: Run the asset check and confirm the five outputs are missing**

Run:

```bash
./scripts/check-profile.sh assets
```

Expected: exit `1`, naming all five missing WebP assets; the retained 3D SVG XML check should pass.

- [ ] **Step 2: Create the deterministic HTML artboard**

Create `scripts/profile-assets.html` with this exact content:

```html
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Aohs Profile Assets</title>
  <style>
    :root {
      --ink: #111314;
      --panel: #1a1d1e;
      --paper: #f4f2ed;
      --muted: #aeb7b2;
      --coral: #ff8fa1;
      --teal: #7edfd0;
      --gold: #ffca66;
      --line: #3a4140;
    }

    * { box-sizing: border-box; }

    html, body {
      margin: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: var(--ink);
      color: var(--paper);
      font-family: Inter, -apple-system, BlinkMacSystemFont, "PingFang SC", "Heiti SC", sans-serif;
      letter-spacing: 0;
    }

    .canvas {
      display: none;
      width: 100vw;
      height: 100vh;
      overflow: hidden;
      background: var(--ink);
    }

    body[data-asset="header"] #header,
    body[data-asset="wfit"] #wfit,
    body[data-asset="aohs"] #aohs,
    body[data-asset="sjg"] #sjg,
    body[data-asset="pet"] #pet {
      display: flex;
    }

    .eyebrow {
      color: var(--teal);
      font-size: 22px;
      font-weight: 700;
      text-transform: uppercase;
    }

    .label {
      font-size: 20px;
      font-weight: 750;
      color: var(--coral);
    }

    .muted { color: var(--muted); }
    .coral { color: var(--coral); }
    .teal { color: var(--teal); }
    .gold { color: var(--gold); }

    .header {
      padding: 54px 58px;
      align-items: stretch;
      gap: 40px;
    }

    .header-copy {
      width: 58%;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .header h1 {
      margin: 10px 0 0;
      font-size: 112px;
      line-height: 1;
      font-weight: 850;
    }

    .header h2 {
      margin: 24px 0 0;
      max-width: 820px;
      font-size: 35px;
      line-height: 1.32;
      font-weight: 720;
    }

    .header p {
      margin: 18px 0 0;
      font-size: 24px;
      line-height: 1.5;
      color: var(--muted);
    }

    .signals {
      display: flex;
      gap: 12px;
      margin-top: 28px;
    }

    .signal {
      padding: 10px 14px;
      border: 1px solid var(--line);
      border-radius: 6px;
      font-size: 18px;
      font-weight: 700;
    }

    .header-media {
      width: 42%;
      display: grid;
      grid-template-columns: 1.25fr .75fr;
      grid-template-rows: 1fr 1fr;
      gap: 10px;
    }

    .media {
      position: relative;
      overflow: hidden;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: #25292a;
    }

    .media.primary { grid-row: 1 / span 2; }
    .media img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .media::after {
      content: attr(data-title);
      position: absolute;
      left: 12px;
      bottom: 12px;
      padding: 7px 10px;
      background: var(--ink);
      color: var(--paper);
      font-size: 14px;
      font-weight: 750;
    }

    .project {
      padding: 46px 52px;
      flex-direction: column;
      gap: 24px;
    }

    .project-head {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      border-bottom: 1px solid var(--line);
      padding-bottom: 22px;
    }

    .project-head h1 {
      margin: 6px 0 0;
      font-size: 50px;
      line-height: 1.16;
    }

    .project-head p {
      max-width: 680px;
      margin: 8px 0 0;
      font-size: 22px;
      line-height: 1.5;
      color: var(--muted);
      text-align: right;
    }

    .flow {
      flex: 1;
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 18px;
      align-items: stretch;
    }

    .stage {
      position: relative;
      padding: 28px;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--panel);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .stage:not(:last-child)::after {
      content: "→";
      position: absolute;
      right: -25px;
      top: 48%;
      color: var(--gold);
      font-size: 28px;
      z-index: 2;
    }

    .stage-no { color: var(--coral); font-size: 17px; font-weight: 800; }
    .stage h2 { margin: 14px 0 0; font-size: 30px; line-height: 1.24; }
    .stage p { margin: 18px 0 0; font-size: 20px; line-height: 1.5; color: var(--muted); }
    .stage strong { color: var(--teal); font-size: 18px; }

    .experience-body {
      flex: 1;
      display: grid;
      grid-template-columns: 1.45fr .55fr;
      gap: 20px;
      min-height: 0;
    }

    .experience-shot {
      overflow: hidden;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: #e9e6df;
    }

    .experience-shot img { width: 100%; height: 100%; object-fit: cover; display: block; }

    .facts {
      display: grid;
      grid-template-rows: repeat(3, 1fr);
      gap: 12px;
    }

    .fact {
      padding: 24px;
      border-radius: 6px;
      color: var(--ink);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .fact:nth-child(1) { background: var(--coral); }
    .fact:nth-child(2) { background: var(--teal); }
    .fact:nth-child(3) { background: var(--gold); }
    .fact span { font-size: 17px; font-weight: 800; }
    .fact strong { font-size: 27px; line-height: 1.2; }

    .map {
      flex: 1;
      position: relative;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: #171a1b;
    }

    .node {
      position: absolute;
      width: 260px;
      min-height: 108px;
      padding: 20px;
      border-radius: 6px;
      border: 1px solid var(--line);
      background: var(--panel);
    }

    .node h2 { margin: 0; font-size: 25px; }
    .node p { margin: 10px 0 0; color: var(--muted); font-size: 17px; line-height: 1.4; }
    .node.city { left: 60px; top: 160px; border-color: var(--teal); }
    .node.poet { left: 480px; top: 55px; border-color: var(--coral); }
    .node.culture { right: 60px; top: 160px; border-color: var(--gold); }
    .node.teaching { left: 480px; bottom: 44px; border-color: #d9dfe3; }
    .node.ai { left: 670px; top: 210px; width: 220px; background: var(--coral); color: var(--ink); }
    .node.ai p { color: #3b282b; }

    .connector {
      position: absolute;
      height: 2px;
      background: #68716d;
      transform-origin: left center;
    }

    .c1 { left: 320px; top: 220px; width: 190px; transform: rotate(-24deg); }
    .c2 { left: 735px; top: 115px; width: 280px; transform: rotate(22deg); }
    .c3 { left: 320px; top: 255px; width: 235px; transform: rotate(31deg); }
    .c4 { left: 735px; top: 420px; width: 280px; transform: rotate(-24deg); }
    .c5 { left: 650px; top: 170px; width: 85px; transform: rotate(63deg); }

    .pet-body {
      flex: 1;
      display: grid;
      grid-template-columns: .72fr 1.28fr;
      gap: 28px;
      min-height: 0;
    }

    .phone {
      justify-self: center;
      width: 310px;
      height: 100%;
      padding: 12px;
      border-radius: 34px;
      background: #25292a;
      border: 2px solid #59615e;
      overflow: hidden;
    }

    .phone img { width: 100%; height: 100%; object-fit: cover; border-radius: 23px; display: block; }

    .ai-flow {
      display: grid;
      grid-template-rows: repeat(5, auto);
      align-content: center;
      gap: 12px;
    }

    .ai-step {
      padding: 20px 24px;
      border-radius: 6px;
      background: var(--panel);
      border: 1px solid var(--line);
      font-size: 23px;
      line-height: 1.35;
    }

    .ai-step strong { color: var(--teal); }
    .ai-step.primary { background: var(--coral); color: var(--ink); border-color: var(--coral); }
    .ai-step.fallback { border-color: var(--gold); }
    .arrow { text-align: center; color: var(--gold); font-size: 24px; }
  </style>
</head>
<body>
  <section id="header" class="canvas header">
    <div class="header-copy">
      <div class="eyebrow">Aohs / Digital Lab</div>
      <h1>Aohs.</h1>
      <h2>Engineering systems.<br><span class="coral">Designing experiences.</span></h2>
      <p>把复杂需求做成真正可用的产品。</p>
      <div class="signals">
        <div class="signal">Java / Full-stack</div>
        <div class="signal">AI Integration</div>
        <div class="signal">Selected Work</div>
      </div>
    </div>
    <div class="header-media">
      <div class="media primary" data-title="Aohs Space"><img src="source/aohs.jpg" alt=""></div>
      <div class="media" data-title="WFIT"><img src="source/wfit.png" alt=""></div>
      <div class="media" data-title="Digital Humanities"><img src="source/sjg.png" alt=""></div>
    </div>
  </section>

  <section id="wfit" class="canvas project">
    <div class="project-head">
      <div><div class="label">01 / BUSINESS SYSTEM</div><h1>WFIT Workload</h1></div>
      <p>将 11 类教学工作量规则收敛为可维护、可审批、可导出的业务系统。</p>
    </div>
    <div class="flow">
      <div class="stage"><div><div class="stage-no">INPUT</div><h2>数据进入</h2><p>排课 Excel、教师自主申报与规则参数统一进入系统。</p></div><strong>Apache POI / Validation</strong></div>
      <div class="stage"><div><div class="stage-no">ENGINE</div><h2>策略计算</h2><p>G1-G11 通过策略接口动态分发，规则参数由 Redis 缓存。</p></div><strong>Java / Spring Boot</strong></div>
      <div class="stage"><div><div class="stage-no">WORKFLOW</div><h2>三级审批</h2><p>教师、教务助理与院领导按权限完成申报、审核与签字。</p></div><strong>Security / JWT</strong></div>
      <div class="stage"><div><div class="stage-no">OUTPUT</div><h2>汇总报表</h2><p>生成个人明细、绩效酬金统计和管理仪表盘。</p></div><strong>Vue 3 / MySQL</strong></div>
    </div>
  </section>

  <section id="aohs" class="canvas project">
    <div class="project-head">
      <div><div class="label">02 / INTERACTIVE EXPERIENCE</div><h1>Aohs Space</h1></div>
      <p>把个人主页从静态介绍升级为可交互、可探索的数字空间。</p>
    </div>
    <div class="experience-body">
      <div class="experience-shot"><img src="source/aohs.jpg" alt=""></div>
      <div class="facts">
        <div class="fact"><span>3D</span><strong>Three.js<br>R3F</strong></div>
        <div class="fact"><span>MOTION</span><strong>GSAP<br>Matter.js</strong></div>
        <div class="fact"><span>EDGE</span><strong>Next.js<br>Cloudflare</strong></div>
      </div>
    </div>
  </section>

  <section id="sjg" class="canvas project">
    <div class="project-head">
      <div><div class="label">03 / DIGITAL HUMANITIES</div><h1>黄河文学景观</h1></div>
      <p>连接山东沿黄地域、文学人物、诗文、景观、非遗与教学交互。</p>
    </div>
    <div class="map">
      <div class="connector c1"></div><div class="connector c2"></div><div class="connector c3"></div><div class="connector c4"></div><div class="connector c5"></div>
      <div class="node city"><h2 class="teal">地域与城市</h2><p>沿黄城市、路线、景观与地域文化。</p></div>
      <div class="node poet"><h2 class="coral">诗人与诗文</h2><p>人物、作品、朝代时间线与文学关系。</p></div>
      <div class="node culture"><h2 class="gold">景观与非遗</h2><p>文化场景、传统技艺、节气与教学素材。</p></div>
      <div class="node teaching"><h2>展示与管理</h2><p>Vue 展示端、管理端、Spring Boot 后端与 React 数据可视化端。</p></div>
      <div class="node ai"><h2>AI 交互</h2><p>诗文分析、创作辅助与内容探索。</p></div>
    </div>
  </section>

  <section id="pet" class="canvas project">
    <div class="project-head">
      <div><div class="label">04 / MOBILE + AI</div><h1>Pet Market</h1></div>
      <p>在真实 Android 产品中连接浏览、百科、收藏与可降级的 AI 顾问。</p>
    </div>
    <div class="pet-body">
      <div class="phone"><img src="source/pet.png" alt=""></div>
      <div class="ai-flow">
        <div class="ai-step primary"><strong>用户问题</strong><br>品种推荐、喂养建议与新手指南</div>
        <div class="arrow">↓</div>
        <div class="ai-step"><strong>Gemini API</strong><br>在线生成针对当前问题的回答</div>
        <div class="arrow">↓ 离线或请求失败</div>
        <div class="ai-step fallback"><strong>本地知识库降级</strong><br>保持核心问答能力可用，数据通过 Room 留在设备端</div>
      </div>
    </div>
  </section>

  <script>
    const allowed = new Set(["header", "wfit", "aohs", "sjg", "pet"]);
    const requested = new URLSearchParams(window.location.search).get("asset") || "header";
    document.body.dataset.asset = allowed.has(requested) ? requested : "header";
  </script>
</body>
</html>
```

- [ ] **Step 3: Create the asset rendering script**

Create `scripts/render-profile-assets.sh` with this exact content:

```bash
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
fetch 'https://raw.githubusercontent.com/qingzhizhu517-rgb/sjg/main/admin-frontend/src/assets/hero.png' "$TEMP_DIR/source/sjg.png"
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
```

Make it executable:

```bash
chmod +x scripts/render-profile-assets.sh
```

- [ ] **Step 4: Render the five assets**

Run:

```bash
./scripts/render-profile-assets.sh
```

Expected:

```text
Rendered assets/brand/aohs-header.webp
Rendered assets/projects/wfit-system.webp
Rendered assets/projects/aohs-space.webp
Rendered assets/projects/sjg-content-map.webp
Rendered assets/projects/pet-market-ai.webp
```

- [ ] **Step 5: Verify format, dimensions, size, and visual framing**

Run:

```bash
./scripts/check-profile.sh assets
sips -g pixelWidth -g pixelHeight assets/brand/aohs-header.webp assets/projects/*.webp
```

Expected: header is `1600 x 520`; every project visual is `1600 x 720`; validation passes and every file is below 900 KB.

Use `view_image` on all five output paths. Confirm:

- No text is clipped or overlaps another element.
- The banner identifies Aohs immediately and shows real project imagery.
- WFIT communicates input, strategy engine, approval, and output.
- Aohs Space uses the real site image rather than a generic illustration.
- The literary landscape diagram makes its content relationships legible.
- Pet Market shows both a real mobile screen and the Gemini fallback path.

- [ ] **Step 6: Commit the asset pipeline and generated outputs**

```bash
git add scripts/profile-assets.html scripts/render-profile-assets.sh assets
git commit -m "feat: add Aohs profile visuals"
```

## Task 3: Rewrite the Profile README Around Verifiable Work

**Files:**

- Modify: `README.md`

- [ ] **Step 1: Run the README check and verify the current template fails**

Run:

```bash
./scripts/check-profile.sh readme
```

Expected: exit `1`; required Aohs copy and local images are missing, while old statistics hosts and unsupported skill claims are still present.

- [ ] **Step 2: Replace `README.md` with the approved content**

Use this exact content:

```markdown
<p align="center">
  <img src="./assets/brand/aohs-header.webp" width="100%" alt="Aohs Digital Lab：Java、全栈产品开发与 AI 应用集成">
</p>

<h1 align="center">Aohs</h1>

<p align="center"><code>@qingzhizhu517-rgb</code></p>

<p align="center">
  <strong>Engineering systems. Designing experiences.</strong><br>
  把复杂需求做成真正可用的产品。
</p>

<p align="center">
  <code>Java / 全栈产品开发 · AI 应用集成</code><br>
  Shandong, China
</p>

<p align="center">
  <a href="https://github.com/qingzhizhu517-rgb">GitHub</a> ·
  <a href="https://aohs.top/">Website</a> ·
  <a href="mailto:qingzhizhu517@gmail.com">Email</a>
</p>

## About / 关于

我是 Aohs，一名以 Java 为核心的全栈产品开发者。我喜欢把规则复杂的业务、富有表达力的交互，以及 AI 能力，收敛为可部署、可维护的真实产品。

## What I Build / 我解决的问题

### 01 / 业务系统

把复杂规则、数据导入、权限与审批流程整理成可以长期维护的系统。主要使用 `Java`、`Spring Boot`、`Vue`、`MySQL` 与 `Redis`。

### 02 / 交互产品

让内容不只被看见，也能被探索和操作。使用 `TypeScript`、`Next.js`、`Three.js`、`GSAP` 与 `Cloudflare` 构建响应式体验。

### 03 / 移动端与 AI 集成

把在线模型能力接入真实应用，同时设计本地存储与失败降级路径。主要使用 `Kotlin`、`Jetpack Compose`、`Room` 与 `Gemini API`。

## Selected Work / 精选项目

以下项目均由我独立设计与开发。每个项目展示的不是完整功能清单，而是最能说明问题与技术决策的部分。

### WFIT Workload

面向教学工作量核算的全流程业务系统。通过策略模式承载 G1-G11 共 11 类计算规则，连接排课 Excel 导入、教师申报、三级审批、绩效酬金与报表导出。

<p align="center">
  <img src="./assets/projects/wfit-system.webp" width="100%" alt="WFIT Workload 从数据输入、策略计算、三级审批到报表输出的系统流程">
</p>

`Java 17` · `Spring Boot` · `Vue 3` · `MySQL` · `Redis` · `Apache POI`

[查看仓库](https://github.com/qingzhizhu517-rgb/wfit--workload)

### Aohs Space

一个可交互的个人数字空间。它将 3D 工牌、流式动画、像素过渡、物理情绪墙和中英文内容组织在同一套 Next.js 应用中，并部署到 Cloudflare Workers。

<p align="center">
  <img src="./assets/projects/aohs-space.webp" width="100%" alt="Aohs Space 真实界面与 Three.js、GSAP、Cloudflare 技术重点">
</p>

`TypeScript` · `Next.js 15` · `React 19` · `Three.js` · `GSAP` · `Cloudflare Workers`

[在线访问](https://aohs.top/) · [查看仓库](https://github.com/qingzhizhu517-rgb/blog-t1)

### 黄河文学景观

围绕黄河流域山东段构建的数字人文与教学应用，连接地域城市、文学人物、诗文、景观、非遗、节气和交互式学习内容。仓库同时包含展示端、管理端、Spring Boot 后端与 React 数据可视化端。

<p align="center">
  <img src="./assets/projects/sjg-content-map.webp" width="100%" alt="黄河文学景观中地域、诗文、文化资源、教学与 AI 交互的内容关系图">
</p>

`Java 17` · `Spring Boot 3.2` · `Vue 3` · `React 19` · `Three.js` · `GSAP` · `ECharts`

[查看仓库](https://github.com/qingzhizhu517-rgb/sjg)

### Pet Market

面向猫狗浏览与品种百科的 Android 应用，包含收藏、内容检索和 Gemini AI 顾问。在线请求不可用时自动切换到本地知识库，保证核心问答路径仍然可用。

<p align="center">
  <img src="./assets/projects/pet-market-ai.webp" width="100%" alt="Pet Market 真实移动端界面以及 Gemini API 到本地知识库的降级流程">
</p>

`Kotlin` · `Jetpack Compose` · `Room` · `Retrofit` · `Gemini API`

[查看仓库](https://github.com/qingzhizhu517-rgb/pet-market)

## Toolbox / 技术坐标

**Core:** `Java` · `Spring Boot` · `Vue` · `TypeScript` · `MySQL` · `Redis`

**Product:** `Next.js` · `Three.js` · `GSAP` · `Cloudflare Workers`

**Mobile & AI:** `Kotlin` · `Jetpack Compose` · `Room` · `Gemini API`

**Currently exploring:** `Spring AI · RAG · LLM 应用架构`

## Contribution Lab

<p align="center">
  <img src="./profile-3d-contrib/profile-night-green.svg" width="100%" alt="Aohs 的 3D GitHub 贡献图">
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/qingzhizhu517-rgb/qingzhizhu517-rgb/output/github-contribution-grid-snake-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/qingzhizhu517-rgb/qingzhizhu517-rgb/output/github-contribution-grid-snake.svg">
    <img src="https://raw.githubusercontent.com/qingzhizhu517-rgb/qingzhizhu517-rgb/output/github-contribution-grid-snake.svg" width="100%" alt="Aohs 的 GitHub 贡献蛇动画">
  </picture>
</p>

## Contact / 联系

欢迎交流 Java、全栈产品开发、交互体验与 AI 应用集成。

[GitHub](https://github.com/qingzhizhu517-rgb) · [aohs.top](https://aohs.top/) · [qingzhizhu517@gmail.com](mailto:qingzhizhu517@gmail.com)
```

- [ ] **Step 3: Run content and structure checks**

Run:

```bash
./scripts/check-profile.sh readme
git diff --check README.md
```

Expected: all README checks pass; `Shandong, China` appears exactly once; no old third-party statistics hosts remain.

- [ ] **Step 4: Ask GitHub to render the Markdown and inspect the sanitized HTML**

Run:

```bash
preview_file=$(mktemp "${TMPDIR:-/tmp}/aohs-readme.XXXXXX")
jq -n --rawfile text README.md '{text:$text, mode:"gfm", context:"qingzhizhu517-rgb/qingzhizhu517-rgb"}' \
  | gh api markdown --input - > "$preview_file"
rg -F 'Aohs Digital Lab' "$preview_file"
rg -F '<picture>' "$preview_file"
rg -F 'WFIT Workload' "$preview_file"
```

Expected: all three searches return matching rendered HTML; GitHub has not removed the `<picture>` element or project images.

- [ ] **Step 5: Commit the README rewrite**

```bash
git add README.md
git commit -m "feat: rebuild profile around selected work"
```

## Task 4: Harden the Two Remaining GitHub Actions

**Files:**

- Modify: `.github/workflows/grid-snake.yml`
- Modify: `.github/workflows/profile-3d.yml`

- [ ] **Step 1: Run workflow checks and verify the current files fail**

Run:

```bash
./scripts/check-profile.sh workflows
```

Expected: exit `1`; current workflows use unpinned references, Snake has a push trigger, and the 3D workflow contains the placeholder email and `ACTIONS_TOKEN` reference.

- [ ] **Step 2: Replace the Snake workflow**

Replace `.github/workflows/grid-snake.yml` with:

```yaml
name: Generate contribution snake

on:
  schedule:
    - cron: "15 1 * * *"
  workflow_dispatch:

permissions:
  contents: write

concurrency:
  group: contribution-snake
  cancel-in-progress: true

jobs:
  generate:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - name: Generate SVG files
        uses: Platane/snk@d8f6715049803e982ee5ff501b6b9b7d5deeb09b
        with:
          github_user_name: ${{ github.repository_owner }}
          outputs: |
            dist/github-contribution-grid-snake.svg
            dist/github-contribution-grid-snake-dark.svg?palette=github-dark
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Publish output branch
        uses: peaceiris/actions-gh-pages@84c30a85c19949d7eee79c4ff27748b70285e453
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_branch: output
          publish_dir: ./dist
          force_orphan: true
          commit_message: "chore: update contribution snake [skip ci]"
```

- [ ] **Step 3: Replace the 3D contribution workflow**

Replace `.github/workflows/profile-3d.yml` with:

```yaml
name: Generate 3D contribution graph

on:
  schedule:
    - cron: "0 18 * * *"
  workflow_dispatch:

permissions:
  contents: write

concurrency:
  group: profile-3d-contribution
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out repository
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262

      - name: Generate contribution graph
        uses: yoshi389111/github-profile-3d-contrib@69fe3757279590c632c16189bb91445b51dc985f
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          USERNAME: ${{ github.repository_owner }}

      - name: Keep selected variant and commit changes
        shell: bash
        run: |
          set -euo pipefail
          selected="profile-3d-contrib/profile-night-green.svg"
          test -s "$selected"
          find profile-3d-contrib -type f ! -name "profile-night-green.svg" -delete

          if git diff --quiet -- "$selected"; then
            echo "No 3D contribution changes to commit."
            exit 0
          fi

          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add "$selected"
          git commit -m "chore: update 3D contribution graph [skip ci]"
          git push
```

- [ ] **Step 4: Parse YAML and run workflow assertions**

Run:

```bash
ruby -e 'require "yaml"; ARGV.each { |path| YAML.safe_load(File.read(path), aliases: true); puts "PASS: #{path}" }' \
  .github/workflows/grid-snake.yml \
  .github/workflows/profile-3d.yml
./scripts/check-profile.sh workflows
git diff --check .github/workflows
```

Expected: both YAML files parse; all pinned-SHA, permission, identity, and trigger checks pass.

- [ ] **Step 5: Commit workflow hardening**

```bash
git add .github/workflows/grid-snake.yml .github/workflows/profile-3d.yml
git commit -m "ci: harden profile asset workflows"
```

## Task 5: Verify, Publish, and Inspect the Live Profile

**Files:**

- Verify all changed files; no planned source modification unless a check reveals a concrete defect.

- [ ] **Step 1: Confirm asset generation is reproducible**

Run:

```bash
before=$(shasum -a 256 assets/brand/aohs-header.webp assets/projects/*.webp)
./scripts/render-profile-assets.sh
after=$(shasum -a 256 assets/brand/aohs-header.webp assets/projects/*.webp)
test "$before" = "$after"
git diff --exit-code -- assets
```

Expected: hashes are identical and `git diff` is empty. If they differ, inspect image loading and font timing before proceeding; do not accept nondeterministic output.

- [ ] **Step 2: Run the full local validation suite**

Run:

```bash
bash -n scripts/check-profile.sh scripts/render-profile-assets.sh
./scripts/check-profile.sh all
./scripts/check-profile.sh links
xmllint --noout profile-3d-contrib/profile-night-green.svg
ruby -e 'require "yaml"; ARGV.each { |path| YAML.safe_load(File.read(path), aliases: true) }' .github/workflows/*.yml
git diff --check
git status --short
```

Expected: all checks pass; `git status --short` prints nothing.

- [ ] **Step 3: Re-render GitHub Markdown after all files are present**

Run:

```bash
preview_file=$(mktemp "${TMPDIR:-/tmp}/aohs-readme-final.XXXXXX")
jq -n --rawfile text README.md '{text:$text, mode:"gfm", context:"qingzhizhu517-rgb/qingzhizhu517-rgb"}' \
  | gh api markdown --input - > "$preview_file"
rg -n 'Aohs Digital Lab|WFIT Workload|Aohs Space|黄河文学景观|Pet Market|Contribution Lab' "$preview_file"
```

Expected: every required section appears in the rendered HTML and no GitHub rendering error is present.

- [ ] **Step 4: Synchronize with automated commits before pushing**

Run:

```bash
git fetch origin
behind=$(git rev-list --count HEAD..origin/main)
if [ "$behind" -gt 0 ]; then
  git rebase origin/main
fi
git status --short --branch
```

Expected: the branch is clean and not behind `origin/main`. If the 3D bot changed the selected SVG during the work, preserve the newer generated SVG and rerun `./scripts/check-profile.sh all` after the rebase.

- [ ] **Step 5: Push the completed profile**

Run:

```bash
git push origin HEAD:main
```

Expected: push succeeds without a forced update.

- [ ] **Step 6: Manually run and watch the Snake workflow**

Run:

```bash
started_at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
gh workflow run grid-snake.yml --ref main
snake_run=''
for attempt in $(seq 1 15); do
  snake_run=$(gh run list --workflow grid-snake.yml --event workflow_dispatch --limit 10 \
    --json databaseId,createdAt \
    --jq ".[] | select(.createdAt >= \"$started_at\") | .databaseId" | head -1)
  [ -n "$snake_run" ] && break
  sleep 2
done
test -n "$snake_run"
gh run watch "$snake_run" --exit-status
```

Expected: workflow completes successfully and the `output` branch retains both SVG files.

- [ ] **Step 7: Manually run and watch the 3D workflow**

Run:

```bash
started_at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
gh workflow run profile-3d.yml --ref main
profile_run=''
for attempt in $(seq 1 15); do
  profile_run=$(gh run list --workflow profile-3d.yml --event workflow_dispatch --limit 10 \
    --json databaseId,createdAt \
    --jq ".[] | select(.createdAt >= \"$started_at\") | .databaseId" | head -1)
  [ -n "$profile_run" ] && break
  sleep 2
done
test -n "$profile_run"
gh run watch "$profile_run" --exit-status
git pull --ff-only origin main
```

Expected: workflow completes successfully. It either reports no change or creates one bot commit that modifies only `profile-3d-contrib/profile-night-green.svg`.

- [ ] **Step 8: Inspect the live GitHub page at desktop and mobile widths**

Run:

```bash
CHROME_BIN='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
"$CHROME_BIN" --headless=new --hide-scrollbars --window-size=1440,1800 \
  --screenshot="${TMPDIR:-/tmp}/aohs-profile-desktop.png" \
  'https://github.com/qingzhizhu517-rgb'
"$CHROME_BIN" --headless=new --hide-scrollbars --window-size=390,844 \
  --screenshot="${TMPDIR:-/tmp}/aohs-profile-mobile.png" \
  'https://github.com/qingzhizhu517-rgb'
```

Use `view_image` on both screenshots. Confirm:

- The Aohs banner is visible and not cropped incoherently.
- Text does not overlap or overflow on mobile.
- All four project images render.
- No broken Stats, Trophy, Activity Graph, visitor, or Star History blocks remain.
- The Night Green contribution graph and snake render.
- GitHub, Website, and Email links are visible.

- [ ] **Step 9: Confirm final repository and remote state**

Run:

```bash
git fetch origin
git status --short --branch
gh run list --limit 6 --json workflowName,status,conclusion,url --jq '.[] | [.workflowName,.status,.conclusion,.url] | @tsv'
```

Expected: local `main` is clean and aligned with `origin/main`; the latest Snake and 3D runs are completed successfully.
