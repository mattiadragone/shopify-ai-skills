---
title: Performance
summary: Lighthouse / Core Web Vitals — thresholds and weighted score, images, fonts, resource hints, CSS/JS bundle size, Liquid loop cost, CLS, predictive search, quick wins.
---

# Performance

Rules for Lighthouse, Core Web Vitals, and page-load speed.

## Theme Store performance threshold

Lighthouse performance ≥ 60 (mobile + desktop) on the home, product, and collection pages.

### Weighted score formula

```
Speed score = [(product_score × 31) + (collection_score × 33) + (home_score × 13)] / 77
```

Must be ≥ 60 for Theme Store acceptance.

### Benchmark setup

1. Import the test product CSV to a development store.
2. Ensure no other products or collections exist — clean baseline only.
3. Test home, product (typical), and collection (typical).

### Lighthouse CI automation

```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on: [pull_request]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: Shopify/lighthouse-ci-action@v1
```

## Core Web Vitals targets

| Metric | Good | Needs improvement | Poor |
|---|---|---|---|
| LCP | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS | ≤ 0.1 | ≤ 0.25 | > 0.25 |

## Images (the #1 LCP factor)

### Responsive `image_tag` with `widths` and `sizes`

```liquid
{{ product.featured_image | image_tag:
   widths: '375,550,750,1100,1500',
   sizes: '(min-width: 1200px) 50vw, (min-width: 750px) 70vw, 100vw',
   loading: 'lazy',
   alt: product.title | escape
}}
```

`widths` generates a `srcset`; `sizes` tells the browser which width to pick.

### Lazy-load below the fold

`loading="eager"` only for the LCP candidate (hero / first product image above the fold). Everything else
`loading="lazy"`. → `knowledge/universal.md` §5.

### Preload the LCP image

```liquid
{%- if section.index == 1 -%}
  <link rel="preload" as="image" href="{{ image | image_url: width: 1100 }}" imagesrcset="…" imagesizes="…">
{%- endif -%}
```

### Modern formats

`image_url` automatically serves WebP / AVIF when supported. No config needed.

## Fonts

```liquid
{{ settings.font_body | font_face: font_display: 'swap' }}
<link rel="preconnect" href="https://fonts.shopifycdn.com">
<link rel="preload" as="font" href="{{ settings.font_body | font_url }}" type="font/woff2" crossorigin>
```

`font-display: swap` shows fallback text immediately (avoids FOIT). Preload only the most critical weight.

## Resource hints

Shopify recommends **at most 2 preload hints per template**. More compete for bandwidth and can hurt LCP.

```liquid
{{ 'base.css' | asset_url | stylesheet_tag: preload: true }}
{{ product.featured_image | image_tag: preload: true, loading: 'eager' }}
```

Count your preloads per template — if > 2, remove the least critical.

## CSS

### Critical CSS in the layout `<head>`

Keep `base.css` small (variables + above-the-fold reset), load it from `layout/theme.liquid` `<head>`
with a normal `<link>` (no defer for CSS — render-blocking is required to avoid FOUC). Lazy-load
template-specific CSS conditionally. → `knowledge/areas/layout.md`, `knowledge/languages/css.md`.

### Section `{% stylesheet %}` global bundle

ALL `{% stylesheet %}` content is bundled into one `section.css` loaded everywhere. Bigger bundle →
slower TTFB. Keep section stylesheets minimal and scoped. If the total exceeds ~50 KB, move cross-cutting
rules to `base.css`.

## JavaScript

### Defer non-critical JS

```liquid
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

Never use `async` for theme JS with ordering dependencies — `defer` preserves document order.

### Bundle size limit

Minified JavaScript per entry point must be **≤ 16 KB**. Larger bundles increase parse time on low-end
mobile.

```bash
esbuild assets/theme.js --bundle --minify | wc -c
```

### IIFE / module scoping

Wrap theme JS in an IIFE (or use ES modules) to avoid polluting the global namespace.

### Avoid heavy frameworks

Don't bundle React/Angular/Vue/jQuery (30–100 KB+). Use native browser APIs and Custom Elements — the
approach in Horizon and Dawn. → `knowledge/languages/javascript.md`.

### Other JS wins

- Don't ship inline `<script>` blocks (parser-blocking) — use `{% javascript %}`.
- Tree-shake third-party libraries; only bundle what you use.
- Loading order matters: framework/library scripts before component scripts (defer = document order).

## Liquid performance

### Avoid heavy work inside `for` loops

```liquid
{# BAD — hits the DB every iteration #}
{% for product in collection.products %}
  {% assign related = product.metafields.custom.related.value %}
{% endfor %}

{# GOOD — fetch once #}
{% liquid
  assign all_related = collection.products | map: 'metafields.custom.related.value'
%}
```

- Limit iterations: `{% for product in collection.products limit: 12 %}`.
- Cache repeated lookups in variables (e.g. `selected_or_first_available_variant`).
- The Shopify Theme Inspector for Chrome shows Liquid render times per template.

## CLS prevention

- All images have explicit `width` and `height` (NOT just CSS).
- Reserve space for above-the-fold lazy content via `min-height` or `aspect-ratio`.
- Avoid injecting content above existing content after load.

## Predictive search

`<predictive-search>` fires on every keystroke. Use a 250–300ms `debounce` and cache the last-result
keyword to avoid redundant fetches.

## Tools

- **Shopify Theme Inspector for Chrome** — Liquid render profiling per section.
- **Lighthouse / PageSpeed Insights** — global page audit.
- **Web Vitals Chrome extension** — live CWV metrics during dev.
- **Chrome Performance tab** — flame chart for INP / long tasks.
- **`lighthouse-ci`** — automate Lighthouse on PR.

## Common quick wins

1. Reduce image sizes (many themes load 2 MB+ of hero images).
2. Defer all non-critical JS.
3. Inline LCP image preload.
4. Remove unused fonts / font weights.
5. Cut down the `section.css` global bundle (scope, deduplicate, move to base.css).
6. Use `font-display: swap`.
7. `loading="lazy"` on below-the-fold images.
8. Replace external embed scripts with native HTML where possible.

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/performance
- https://shopify.dev/docs/storefronts/themes/tools/theme-inspector
- https://web.dev/vitals/
- https://shopify.dev/docs/api/liquid/filters/image_tag
