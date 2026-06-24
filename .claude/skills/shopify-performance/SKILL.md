---
name: shopify-performance
description: Use when optimizing a theme for Lighthouse, Core Web Vitals, or page-load speed. Covers image lazy loading, font-display strategies, defer vs async scripts, Liquid loops cost, the global section.css/section.js bundle size, image_tag responsive widths, and predictive search load patterns.
---

# Shopify Performance

## When to invoke

- Lighthouse performance score < 60 on product / collection / home.
- Slow LCP / FID / CLS reported in Web Vitals or Google Search Console.
- Investigating a slow page after a feature was added.
- Auditing CSS / JS bundle sizes before submission.

## Always pair with

- `shopify-base` — lazy loading and defer are defined here as universal rules
- `shopify-javascript` — JS bundle size, defer order, and IIFE scoping affect performance
- `shopify-css` — `{% stylesheet %}` bundle size and conditional template loading
- `shopify-assets` — image optimization, `image_tag` widths, and font loading patterns

## Theme Store performance threshold

Lighthouse performance ≥ 60 (mobile + desktop) on:

- Home page
- Product page (a typical product)
- Collection page (a typical collection)

Tested with the Shopify Theme Inspector and `lighthouse-ci`.

### Weighted score formula

Shopify uses this formula to calculate the overall speed score:

```
Speed score = [(product_score × 31) + (collection_score × 33) + (home_score × 13)] / 77
```

The result must be ≥ 60 for Theme Store acceptance.

### Benchmark setup

Before testing Lighthouse scores for Theme Store submission:

1. Import the [test product CSV](https://shopify.dev/docs/storefronts/themes/best-practices/performance/lighthouse) to your development store.
2. Ensure no other products or collections exist — clean baseline only.
3. Test home page, product page (a typical product), and collection page.

### Lighthouse CI automation

Add the Shopify Lighthouse CI GitHub Action to catch regressions on every PR:

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

Reference: https://github.com/Shopify/lighthouse-ci-action

## Core Web Vitals targets

| Metric | Good | Needs improvement | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |

## Images (the #1 LCP factor)

### Use `image_tag` with responsive `widths` and `sizes`

```liquid
{{ product.featured_image | image_tag:
   widths: '375,550,750,1100,1500',
   sizes: '(min-width: 1200px) 50vw, (min-width: 750px) 70vw, 100vw',
   loading: 'lazy',
   alt: product.title | escape
}}
```

`widths` generates a `srcset`. `sizes` tells the browser which width to pick for the current viewport.

### Lazy-load below the fold

```liquid
{{ image | image_tag: loading: 'lazy', fetchpriority: 'low' }}
```

`loading="eager"` only for the LCP candidate (typically the hero / first product image above the fold).

### Preload the LCP image

```liquid
{%- if section.index == 1 -%}
  <link rel="preload" as="image" href="{{ image | image_url: width: 1100 }}" imagesrcset="…" imagesizes="…">
{%- endif -%}
```

### Use modern formats automatically

`image_url` automatically serves WebP / AVIF when the browser supports it. No special config needed.

## Fonts

Use Shopify's font system for theme fonts:

```liquid
{{ settings.font_body | font_face: font_display: 'swap' }}
{{ settings.font_heading | font_face: font_display: 'swap' }}

<link rel="preconnect" href="https://fonts.shopifycdn.com">
```

`font-display: swap` shows fallback text immediately while custom font loads (avoids FOIT).

Preload only the most critical font weight:

```liquid
<link rel="preload" as="font" href="{{ settings.font_body | font_url }}" type="font/woff2" crossorigin>
```

## Resource hints

Shopify recommends **at most 2 preload hints per template**. More than 2 compete for bandwidth and can hurt LCP by delaying other critical resources.

Use `preload_tag` or the `preload:` keyword on `image_tag` / `stylesheet_tag`:

```liquid
{{ 'base.css' | asset_url | stylesheet_tag: preload: true }}
{{ product.featured_image | image_tag: preload: true, loading: 'eager' }}
```

Count your preloads per template — if > 2, remove the least critical ones.

## CSS

### Inline critical CSS in the layout `<head>`

Cleanest Shopify pattern: keep `base.css` small (variables + above-the-fold reset), load it from `layout/theme.liquid` `<head>` with normal `<link>` (no defer for CSS — render-blocking is required to avoid FOUC).

Lazy-load template-specific CSS conditionally:

```liquid
{%- if template contains 'product' -%}
  {{ 'template-product.css' | asset_url | stylesheet_tag }}
{%- endif -%}
```

### Section `{% stylesheet %}` global bundle

ALL `{% stylesheet %}` content across sections / blocks / snippets is bundled into one `section.css` file loaded everywhere. Bigger bundle → slower TTFB. Keep section stylesheets minimal and scope rules to avoid duplicates.

Audit:

```bash
# Estimated total size of all {% stylesheet %} content
grep -h -A 999 '{%- stylesheet -%}' sections/*.liquid snippets/*.liquid blocks/*.liquid 2>/dev/null \
  | sed '/{%- endstylesheet -%}/,$d' | wc -c
```

If > 50 KB, consider moving cross-cutting rules to `base.css` instead.

### CSS subsetting compatibility

Shopify automatically subsets (removes unused CSS) from theme stylesheets. For subsetting to work correctly, CSS classes must only be used within the file that defines them. Don't reference a class defined in `base.css` from inside a `{% stylesheet %}` block — the subsetter may remove it.

## JavaScript

### Defer non-critical JS

```liquid
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

Never use `async` for theme JS that has ordering dependencies. `defer` preserves document order.

### Bundle size limit

Minified JavaScript per theme entry point must be **≤ 16 KB**. Larger bundles increase parse time on low-end mobile.

```bash
# Check minified size of a bundle
esbuild assets/theme.js --bundle --minify | wc -c
```

### IIFE pattern for namespace safety

Wrap theme JS in an IIFE to avoid polluting the global namespace and colliding with apps or Shopify's own scripts:

```js
(function () {
  'use strict';
  // theme code here
})();
```

Alternatively, use ES modules (`type="module"`) — they are scoped by default.

### Avoid heavy external frameworks

Don't bundle React, Angular, Vue, or jQuery. These add 30–100 KB+ minified and dominate the 16 KB budget. Use native browser APIs and Custom Elements instead — the approach used by Shopify's own Horizon and Dawn themes.

### Don't ship inline `<script>` blocks

`<script>` (no `src`) blocks the parser. Use `{% javascript %}` (auto-deferred section bundle) for section-scoped JS.

### Tree-shake third-party libraries

If you only use Swiper's core, don't bundle the full Swiper-element-bundle. Build a smaller version (third-party libs are exempt from the no-minified rule).

### Loading order matters

Shopify defer execution order matches document order. Put framework / library scripts before component scripts:

```liquid
<script src="{{ 'pubsub.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'swiper-element-bundle.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'animations.js' | asset_url }}" defer="defer"></script>
```

## Liquid performance

### Avoid heavy work inside `for` loops

```liquid
{# BAD — hits the DB for every iteration #}
{% for product in collection.products %}
  {% assign related = product.metafields.custom.related.value %}
{% endfor %}

{# GOOD — fetch once, iterate #}
{% liquid
  assign all_related = collection.products | map: 'metafields.custom.related.value'
%}
```

### Limit collection / product iterations

```liquid
{% for product in collection.products limit: 12 %}
```

The Shopify Theme Inspector for Chrome shows Liquid render times per template — use it to find the slowest loops.

### Cache repeated lookups in variables

```liquid
{%- liquid
  assign current_variant = product.selected_or_first_available_variant
  assign price_class = product.price_varies ? 'price--varies' : 'price--fixed'
-%}
```

## CLS prevention

- All images have explicit `width` and `height` attributes (NOT just CSS).
- Reserve space for above-the-fold lazy content via `min-height` or `aspect-ratio`.
- Avoid injecting content above existing content after page load.

```liquid
{{ image | image_tag: widths: '...', sizes: '...', loading: 'lazy', width: image.width, height: image.height }}
```

## Predictive search

If you use `<predictive-search>`, the request fires on every keystroke. Use:

- `debounce` of 250–300ms in JS.
- Cache last-result keyword to avoid redundant fetches.

```js
let lastQuery = '';
input.addEventListener('input', debounce((e) => {
  if (e.target.value === lastQuery) return;
  lastQuery = e.target.value;
  fetch(`/search/suggest.json?q=${e.target.value}`);
}, 300));
```

## Tools

- **Shopify Theme Inspector for Chrome** — Liquid render profiling per section.
- **Lighthouse / PageSpeed Insights** — global page audit.
- **Web Vitals Chrome extension** — live CWV metrics during dev.
- **Chrome Performance tab** — flame chart for INP / long tasks.
- **`lighthouse-ci`** in CI — automate Lighthouse runs on PR.

## Common quick wins

1. Reduce image sizes (most themes load 2 MB+ of hero images).
2. Defer all non-critical JS.
3. Inline LCP image preload.
4. Remove unused fonts / font weights.
5. Cut down on the `section.css` global bundle (scope, deduplicate, move to base.css).
6. Use `font-display: swap`.
7. Set `loading="lazy"` on below-the-fold images.
8. Replace external embed scripts with native HTML where possible.

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/performance
- https://shopify.dev/docs/storefronts/themes/best-practices/performance
- https://shopify.dev/docs/storefronts/themes/tools/theme-inspector
- https://web.dev/vitals/
- https://shopify.dev/docs/api/liquid/filters/image_tag
