---
name: shopify-audit-submission
description: Use when preparing a Shopify theme for Theme Store submission. Runs a full compliance checklist: required templates, section group structure, @app/@theme block support, code rules, color scheme count, font picker variants, and Partner Program compliance.
---

# Shopify Submission Audit

Run after `shopify-audit-critical` and `shopify-audit-quality`. All issues from those must be resolved first.

## When to invoke

- Before first Theme Store submission.
- After a major update to verify continued eligibility.
- When Shopify reviewers reject a submission.

## Checks

### 1 — Required templates · `shopify-templates` + `shopify-theme-store` · **BLOCKING**

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
for f in "${required[@]}"; do
  [ -f "$f" ] && echo "OK: $f" || echo "MISSING: $f"
done
```

### 2 — Section groups · `shopify-layout` · **BLOCKING**

```bash
grep '"type"' sections/header-group.json sections/footer-group.json 2>/dev/null
grep "{% sections\|{% section " layout/theme.liquid
```

Must use `{% sections 'header-group' %}`, not `{% section 'header' %}`.

### 3 — `@theme` and `@app` block support · `shopify-blocks` · **BLOCKING**

```bash
grep -l '"presets"' sections/*.liquid | while read f; do
  grep -q '"@theme"' "$f" || echo "MISSING @theme: $f"
  grep -q '"@app"' "$f" || echo "MISSING @app: $f"
done
```

### 4 — Code rules · `shopify-assets` + `shopify-css` + `shopify-javascript` · **BLOCKING**

```bash
find assets/ -name "*.scss" -o -name "*.sass" -o -name "*.map" 2>/dev/null
[ -d "node_modules" ] && echo "FAIL: node_modules committed"
awk 'length > 500 {print FILENAME": line "NR; found=1} END{exit !found}' assets/*.css 2>/dev/null \
  && echo "WARN: possible minified CSS"
grep -rn 'eval(\|atob(\|fromCharCode(' assets/global.js assets/theme.js 2>/dev/null \
  && echo "FAIL: obfuscation pattern"
```

### 5 — Hardcoded strings · `shopify-locales` · **BLOCKING**

```bash
grep -rn "{{[^}]*'[A-Z][a-z]" sections/ snippets/ templates/ 2>/dev/null \
  | grep -v "| t\b\|| escape\|| money\|| date\|| handle\|| asset_url" | head -20
```

### 6 — Color schemes (≥ 4) · `shopify-config` · **BLOCKING**

```bash
grep -c '"color_scheme_group"' config/settings_schema.json 2>/dev/null
```

### 7 — Font picker variants · `shopify-config` · **HIGH**

```bash
grep -n '"font_picker"' config/settings_schema.json sections/*.liquid 2>/dev/null
```

Check each picker's `"default"` family supports `_n7`, `_i4`, `_i7` variants.

### 8 — Accelerated checkout · `shopify-theme-store` · **BLOCKING**

```bash
grep -rn "payment_button" sections/*.liquid templates/cart.json 2>/dev/null
```

### 9 — Gift card · `shopify-templates` · **BLOCKING**

```bash
grep -n "gift_card\|code\|expiry\|download" templates/gift_card.liquid 2>/dev/null
```

### 10 — Predictive search · `shopify-theme-store` · **BLOCKING**

```bash
grep -rn "predictive-search\|search/suggest\|PredictiveSearch" snippets/ sections/ assets/ 2>/dev/null
```

### 11 — Partner Program compliance · `shopify-theme-store` · **BLOCKING** (manual)

- [ ] No obfuscated code
- [ ] No search engine cloaking
- [ ] No mock data or fake orders in templates
- [ ] Theme works with zero apps installed
- [ ] No dark patterns
- [ ] Third-party LICENSE files present

## Output template

```
Submission Audit — <theme> — <version> — <date>

1  Required templates:   PASS / FAIL — <missing>
2  Section groups:       PASS / FAIL
3  @theme + @app:        PASS / FAIL — <sections missing>
4  Code rules:           PASS / FAIL — <violations>
5  Hardcoded strings:    PASS / FAIL — <N>
6  Color schemes:        <N> (need ≥4)
7  Font variants:        PASS / FAIL
8  Accelerated checkout: PASS / FAIL
9  Gift card:            PASS / FAIL
10 Predictive search:    PASS / FAIL
11 Partner compliance:   PASS / FAIL — <issues>

Blocking before submitting: <list>
```
