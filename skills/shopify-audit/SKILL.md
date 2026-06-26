---
name: shopify-audit
description: Use when inspecting an existing Shopify theme repo for problems — before a merge, before a Theme Store submission, or to diagnose a Lighthouse/a11y drop. Read-only. Runs shopify theme check plus targeted greps across three levels (critical, quality, submission) and reports each finding with severity, location, what to change, why it matters, and a link to the knowledge file that explains it.
---

# Shopify Audit

**Action:** inspect an existing theme repo and produce a findings report. **Read-only — never edit code
here.** To fix what the audit finds, hand off to `shopify-build`.

Findings draw their "why" from the knowledge base — `${CLAUDE_PLUGIN_ROOT}/knowledge/` when installed as
a plugin, or `knowledge/` at the repo root from a clone. Each reported issue should cite the knowledge
file a developer can read to understand and fix it (paths below are written relative to the repo root for
readability).

## When to invoke

- Before merging a feature branch.
- Before a Theme Store submission.
- After a major refactor, or when Lighthouse/a11y scores drop.

## Levels

Run the level the task needs. For a full pre-submission review, run all three in order — fix the blocking
findings from each level before moving to the next.

- **Level 1 — Critical**: blocking correctness errors.
- **Level 2 — Quality**: performance and accessibility.
- **Level 3 — Submission**: Theme Store compliance.

Always start with `shopify theme check` — it catches many issues the greps below also target, with exact
locations.

```bash
shopify theme check --fail-level error      # blocking errors (use in CI)
shopify theme check                          # full report incl. warnings
```

Key checks it surfaces: `ParserBlockingScript` (no defer), `ImgWidthAndHeight` (CLS),
`TranslationKeyExists` (missing `t:`), `MissingTemplate`, `RemoteAsset`, `AssetSizeAppBlockCSS`.
→ configure via `.theme-check.yml` (see `shopify-tooling`).

---

## Level 1 — Critical checks

### 1.1 CSS scoping leaks · `knowledge/languages/css.md` · BLOCKING

```bash
grep -rn "{%[- ]*stylesheet" sections/ blocks/ snippets/ 2>/dev/null \
  | awk -F: '{print $1}' | sort -u \
  | xargs -I{} grep -A200 "{%[- ]*stylesheet" {} \
  | grep -E "^\s*(html|body|\*|[a-z]+\[|\.[a-z_-]+\s*\{)" | head -30
```

Unscoped selectors leak into the global `section.css`. Fix: prefix every selector with the component's
class. Why: `knowledge/universal.md` §1.

### 1.2 Missing `t:` prefixes · `knowledge/areas/locales.md` · BLOCKING

```bash
grep -rn '"label"\|"info"\|"name"\|"content"' sections/ blocks/ config/ 2>/dev/null \
  | grep -v '"t:' \
  | grep -v 'theme_name\|theme_author\|theme_documentation\|theme_support\|theme_version\|"default"\|"id"\|"type"\|"value"' \
  | head -40
```

Hardcoded schema strings are rejected. Fix: replace with `t:` keys defined in `en.default.schema.json`.
Why: `knowledge/universal.md` §2.

### 1.3 Missing `block.shopify_attributes` · `knowledge/areas/blocks.md` · BLOCKING

```bash
for f in blocks/*.liquid; do
  grep -q "block.shopify_attributes" "$f" || echo "MISSING: $f"
done
```

Without it the block is not selectable in the editor. Why: `knowledge/universal.md` §4.

### 1.4 Scripts without `defer` · `knowledge/languages/javascript.md` · HIGH

```bash
grep -rn '<script src=' layout/ sections/ snippets/ templates/ 2>/dev/null \
  | grep -v 'defer' | grep -v '<!--' | head -20
```

Parser-blocking scripts tank Lighthouse. Fix: add `defer`. Why: `knowledge/universal.md` §3.

### 1.5 Images without `alt` · `knowledge/quality/accessibility.md` · HIGH

```bash
grep -rn '<img' sections/ snippets/ blocks/ templates/ 2>/dev/null | grep -v 'alt=' | head -20
grep -rn 'image_tag' sections/ snippets/ blocks/ templates/ 2>/dev/null | grep -v 'alt:' | head -20
```

### 1.6 Images without `width`/`height` · `knowledge/quality/performance.md` · HIGH

```bash
grep -rn 'image_tag' sections/ snippets/ blocks/ 2>/dev/null \
  | grep -v 'width:.*height:\|widths:' | head -20
```

Missing dimensions cause CLS. Why: `knowledge/universal.md` §5.

### 1.7 Deprecated `{% include %}` · `knowledge/languages/liquid.md` · MEDIUM

```bash
grep -rn "{%[- ]* include " sections/ snippets/ blocks/ templates/ layout/ 2>/dev/null | head -20
```

Fix: replace with `{% render %}` and pass variables explicitly.

---

## Level 2 — Quality checks

### 2.1 Lighthouse scores · `knowledge/quality/performance.md` + `accessibility.md` · BLOCKING

```bash
npx lighthouse <url>/products/<handle> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
npx lighthouse <url>/collections/<handle> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
npx lighthouse <url> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
```

Weighted speed score: `[(product×31) + (collection×33) + (home×13)] / 77` — must be ≥ 60; a11y ≥ 90.

### 2.2 JS bundle size · `knowledge/quality/performance.md` · HIGH

```bash
esbuild assets/global.js --bundle --minify 2>/dev/null | wc -c
```

Limit 16 KB minified per entry point.

### 2.3 `{% stylesheet %}` bundle size · `knowledge/languages/css.md` · MEDIUM

```bash
awk '/\{% stylesheet %\}/{p=1} p{print} /\{% endstylesheet %\}/{p=0}' \
  sections/*.liquid blocks/*.liquid snippets/*.liquid 2>/dev/null | wc -c
```

Warn above 50 KB — move cross-cutting rules to `assets/base.css`.

### 2.4 Preload count · `knowledge/quality/performance.md` · MEDIUM

```bash
grep -rn 'rel="preload"\|preload: true' layout/ snippets/ sections/ 2>/dev/null
```

Limit 2 per template (LCP image + critical CSS).

### 2.5 LCP image preload · `knowledge/quality/performance.md` · HIGH

```bash
grep -n 'loading.*eager\|fetchpriority.*high\|rel="preload".*image' \
  layout/theme.liquid snippets/*.liquid 2>/dev/null | head -10
```

### 2.6 Touch target sizes · `knowledge/quality/accessibility.md` · HIGH

```bash
grep -rn 'class=".*close\|class=".*hamburger\|class=".*cart.*icon\|class=".*nav.*toggle' \
  sections/ layout/ snippets/ 2>/dev/null | head -20
grep -n 'min-width.*44\|min-height.*44' assets/base.css 2>/dev/null
```

Primary controls must be ≥ 44×44 px.

### 2.7 Focus indicators · `knowledge/quality/accessibility.md` · HIGH

```bash
grep -n "focus-visible\|:focus" assets/base.css 2>/dev/null
grep -rn "outline:\s*none\|outline:\s*0" assets/ sections/ snippets/ 2>/dev/null | head -20
```

### 2.8 Reduced motion · `knowledge/languages/css.md` · MEDIUM

```bash
grep -rn "prefers-reduced-motion" assets/*.css 2>/dev/null
```

### 2.9 Font display swap · `knowledge/quality/performance.md` · MEDIUM

```bash
grep -n "font_face\|font-display\|font_url\|preload.*font" \
  layout/theme.liquid snippets/*.liquid 2>/dev/null | head -10
```

### 2.10 Lazy loading below the fold · `knowledge/quality/performance.md` · MEDIUM

```bash
grep -rn 'image_tag' sections/ snippets/ blocks/ 2>/dev/null \
  | grep -v "loading: 'lazy'\|loading: lazy" | head -20
```

---

## Level 3 — Submission checks

Run after Levels 1 and 2 are clean. → `knowledge/quality/theme-store.md`.

### 3.1 Required templates · BLOCKING

```bash
required=(
  templates/index.json templates/product.json templates/collection.json
  templates/list-collections.json templates/blog.json templates/article.json
  templates/page.json templates/cart.json templates/search.json
  templates/404.json templates/password.json templates/gift_card.liquid
  templates/customers/login.liquid templates/customers/register.liquid
  templates/customers/account.liquid templates/customers/order.liquid
  templates/customers/addresses.liquid templates/customers/activate_account.liquid
  templates/customers/reset_password.liquid
  layout/password.liquid sections/header-group.json sections/footer-group.json
)
for f in "${required[@]}"; do [ -f "$f" ] && echo "OK: $f" || echo "MISSING: $f"; done
```

### 3.2 Section groups · BLOCKING

```bash
grep '"type"' sections/header-group.json sections/footer-group.json 2>/dev/null
grep "{% sections\|{% section " layout/theme.liquid
```

Header/footer must use `{% sections 'header-group' %}`, not `{% section 'header' %}`.

### 3.3 `@theme` and `@app` block support · BLOCKING

```bash
grep -l '"presets"' sections/*.liquid | while read f; do
  grep -q '"@theme"' "$f" || echo "MISSING @theme: $f"
  grep -q '"@app"' "$f" || echo "MISSING @app: $f"
done
```

### 3.4 Code rules · BLOCKING

```bash
find assets/ -name "*.scss" -o -name "*.sass" -o -name "*.map" 2>/dev/null
[ -d "node_modules" ] && echo "FAIL: node_modules committed"
grep -rn 'eval(\|atob(\|fromCharCode(' assets/global.js assets/theme.js 2>/dev/null \
  && echo "FAIL: obfuscation pattern"
```

### 3.5 Hardcoded strings · BLOCKING

```bash
grep -rn "{{[^}]*'[A-Z][a-z]" sections/ snippets/ templates/ 2>/dev/null \
  | grep -v "| t\b\|| escape\|| money\|| date\|| handle\|| asset_url" | head -20
```

### 3.6 Color schemes (≥ 4) · BLOCKING

```bash
grep -c '"color_scheme_group"' config/settings_schema.json 2>/dev/null
```

### 3.7 Font picker variants · HIGH

```bash
grep -n '"font_picker"' config/settings_schema.json sections/*.liquid 2>/dev/null
```

Each picker's `default` family must support `_n7`, `_i4`, `_i7`.

### 3.8 Accelerated checkout · BLOCKING

```bash
grep -rn "payment_button" sections/*.liquid templates/cart.json 2>/dev/null
```

### 3.9 Gift card · BLOCKING

```bash
grep -n "gift_card\|code\|expiry\|download" templates/gift_card.liquid 2>/dev/null
```

### 3.10 Predictive search · BLOCKING

```bash
grep -rn "predictive-search\|search/suggest\|PredictiveSearch" snippets/ sections/ assets/ 2>/dev/null
```

### 3.11 Partner Program compliance · BLOCKING (manual)

- [ ] No obfuscated code · No search engine cloaking · No mock data / fake orders
- [ ] Works with zero apps installed · No dark patterns · Third-party LICENSE files present

---

## Output format

Report every finding so a developer can act without re-running anything. For each issue include:

```
[SEVERITY] <check> — <file:line>
  Problem:  <what is wrong>
  Fix:      <what to change>
  Why:      <one line> → knowledge/<file>.md
```

Then a summary scoreboard per level, e.g.:

```
Critical Audit — <theme> — <date>
1.1 CSS scoping:        PASS / FAIL — <files>
1.2 t: prefixes:        PASS / FAIL — <files>
...
theme-check:            <N errors / N warnings>
Blocking before merge:  <list>
```

Order the "fix next" list by severity, then by Lighthouse impact for quality findings.

## Example prompts

- "Audit the theme before I merge this branch."
- "Run a critical audit and tell me what's blocking."
- "Check this theme for Theme Store submission readiness."
- "Why did my Lighthouse score drop? Run the quality audit."

## References

- Knowledge base index: `knowledge/README.md`
- https://shopify.dev/docs/storefronts/themes/tools/theme-check
- https://shopify.dev/docs/storefronts/themes/store/requirements
