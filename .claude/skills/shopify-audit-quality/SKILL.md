---
name: shopify-audit-quality
description: Use when auditing an existing Shopify theme repo for performance and accessibility quality. Runs Lighthouse score checks, JS bundle size, preload count, touch target sizes, focus indicators, and reduced-motion support. Does NOT build code — inspects existing files and reports findings.
---

# Shopify Quality Audit

## When to invoke

- Lighthouse performance < 60 or accessibility < 90 on any required page.
- After adding new sections, sliders, or media-heavy content.
- Before a Theme Store submission quality check.

## Checks

### 1 — Lighthouse scores · `shopify-performance` + `shopify-accessibility` · **BLOCKING**

```bash
npx lighthouse <url>/products/<handle> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
npx lighthouse <url>/collections/<handle> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
npx lighthouse <url> --output json --quiet \
  | jq '.categories.performance.score, .categories.accessibility.score'
```

Weighted speed score: `[(product×31) + (collection×33) + (home×13)] / 77` — must be ≥ 60.

### 2 — JS bundle size · `shopify-javascript` · **HIGH**

```bash
esbuild assets/global.js --bundle --minify 2>/dev/null | wc -c
```

Limit: 16 KB minified.

### 3 — `{% stylesheet %}` bundle size · `shopify-css` · **MEDIUM**

```bash
awk '/\{% stylesheet %\}/{p=1} p{print} /\{% endstylesheet %\}/{p=0}' \
  sections/*.liquid blocks/*.liquid snippets/*.liquid 2>/dev/null | wc -c
```

Warn above 50 KB — move cross-cutting rules to `assets/base.css`.

### 4 — Preload count · `shopify-performance` · **MEDIUM**

```bash
grep -rn 'rel="preload"\|preload: true' layout/ snippets/ sections/ 2>/dev/null
```

Limit: 2 per template. Remove any beyond the LCP image and critical CSS.

### 5 — LCP image preload · `shopify-performance` · **HIGH**

```bash
grep -n 'loading.*eager\|fetchpriority.*high\|rel="preload".*image' \
  layout/theme.liquid snippets/*.liquid 2>/dev/null | head -10
```

### 6 — Touch target sizes · `shopify-accessibility` · **HIGH**

```bash
grep -rn 'class=".*close\|class=".*hamburger\|class=".*cart.*icon\|class=".*nav.*toggle' \
  sections/ layout/ snippets/ 2>/dev/null | head -20
grep -n 'min-width.*44\|min-height.*44' assets/base.css 2>/dev/null
```

Primary controls must be ≥ 44×44 px.

### 7 — Focus indicators · `shopify-accessibility` + `shopify-css` · **HIGH**

```bash
grep -n "focus-visible\|:focus" assets/base.css 2>/dev/null
grep -rn "outline:\s*none\|outline:\s*0" assets/ sections/ snippets/ 2>/dev/null | head -20
```

### 8 — Reduced motion · `shopify-css` · **MEDIUM**

```bash
grep -rn "prefers-reduced-motion" assets/*.css 2>/dev/null
```

### 9 — Font display swap · `shopify-performance` · **MEDIUM**

```bash
grep -n "font_face\|font-display\|font_url\|preload.*font" \
  layout/theme.liquid snippets/*.liquid 2>/dev/null | head -10
```

### 10 — Lazy loading below fold · `shopify-base` · **MEDIUM**

```bash
grep -rn 'image_tag' sections/ snippets/ blocks/ 2>/dev/null \
  | grep -v "loading: 'lazy'\|loading: lazy" | head -20
```

## Output template

```
Quality Audit — <theme> — <date>

1 Lighthouse:      product=<X> collection=<X> home=<X> speed=<calc>
2 JS bundle:       <X KB> PASS/FAIL
3 CSS bundle:      <X KB> PASS/FAIL
4 Preload count:   <N> PASS/FAIL
5 LCP preload:     PRESENT / MISSING
6 Touch targets:   PASS / FAIL — <elements>
7 Focus outline:   PASS / FAIL — <violations>
8 Reduced motion:  PRESENT / MISSING
9 Font swap:       PRESENT / MISSING
10 Lazy load:      PASS / FAIL — <N eager below fold>

Priority fixes: <list by Lighthouse impact>
```
