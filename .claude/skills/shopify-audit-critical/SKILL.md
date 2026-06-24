---
name: shopify-audit-critical
description: Use when auditing an existing Shopify theme repo for critical correctness errors. Runs severity-1 checks: CSS scoping leaks, missing t: prefixes, missing block.shopify_attributes, undeferred scripts, images without alt or dimensions, and theme-check violations. Does NOT build code — inspects existing files.
---

# Shopify Critical Audit

## When to invoke

- Before merging a feature branch to main.
- Before opening a Theme Store submission.
- After a major refactor to catch regressions.

## Checks

### 1 — CSS scoping leaks · `shopify-css` · **BLOCKING**

```bash
grep -rn "{%[- ]*stylesheet" sections/ blocks/ snippets/ 2>/dev/null \
  | awk -F: '{print $1}' | sort -u \
  | xargs -I{} grep -A200 "{%[- ]*stylesheet" {} \
  | grep -E "^\s*(html|body|\*|[a-z]+\[|\.[a-z_-]+\s*\{)" | head -30
```

### 2 — Missing `t:` prefixes · `shopify-base` · **BLOCKING**

```bash
grep -rn '"label"\|"info"\|"name"\|"content"' sections/ blocks/ config/ 2>/dev/null \
  | grep -v '"t:' \
  | grep -v 'theme_name\|theme_author\|theme_documentation\|theme_support\|theme_version\|"default"\|"id"\|"type"\|"value"' \
  | head -40
```

### 3 — Missing `block.shopify_attributes` · `shopify-blocks` · **BLOCKING**

```bash
for f in blocks/*.liquid; do
  grep -q "block.shopify_attributes" "$f" || echo "MISSING: $f"
done
```

### 4 — Scripts without `defer` · `shopify-base` · **HIGH**

```bash
grep -rn '<script src=' layout/ sections/ snippets/ templates/ 2>/dev/null \
  | grep -v 'defer' | grep -v '<!--' | head -20
```

### 5 — Images without `alt` · `shopify-accessibility` · **HIGH**

```bash
grep -rn '<img' sections/ snippets/ blocks/ templates/ 2>/dev/null | grep -v 'alt=' | head -20
grep -rn 'image_tag' sections/ snippets/ blocks/ templates/ 2>/dev/null | grep -v 'alt:' | head -20
```

### 6 — Images without `width`/`height` · `shopify-performance` · **HIGH**

```bash
grep -rn 'image_tag' sections/ snippets/ blocks/ 2>/dev/null \
  | grep -v 'width:.*height:\|widths:' | head -20
```

### 7 — Deprecated `{% include %}` · `shopify-liquid` · **MEDIUM**

```bash
grep -rn "{%[- ]* include " sections/ snippets/ blocks/ templates/ layout/ 2>/dev/null | head -20
```

### 8 — theme-check · `shopify-tooling` · **ALL**

```bash
shopify theme check --fail-level error
```

## Output template

```
Critical Audit — <theme> — <date>

1 CSS scoping:          PASS / FAIL — <files>
2 t: prefixes:          PASS / FAIL — <files>
3 block.shopify_attrs:  PASS / FAIL — <files>
4 defer:                PASS / FAIL — <N scripts>
5 img alt:              PASS / FAIL — <N images>
6 dimensions:           PASS / FAIL — <N images>
7 include:              PASS / FAIL — <N occurrences>
8 theme-check:          PASS / FAIL — <N errors>

Blocking: <list>
```
