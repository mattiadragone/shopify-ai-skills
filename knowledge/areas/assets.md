---
title: Assets
summary: Rules for the assets/ directory — flat-directory constraint, asset_url/image_url/inline_asset_content, SVG a11y, organization, Theme Store code rules.
---

# Assets

Rules for files in `assets/` (CSS, JS, images, fonts, SVG icons).

## The flat-directory rule

`assets/` is **flat** — no subdirectories. Every file lives at the top of `assets/`. Enforced by Shopify.

Naming conventions to compensate:

- `component-X.css`, `section-X.css`, `template-X.css` (legacy/Dawn).
- `template-product.css`, `template-collection.css`, `template-blog-the-skin-edit.css` (template-scoped).
- `icon-arrow.svg`, `icon-cart.svg` (icons).

## Referencing assets

### `asset_url` filter

```liquid
{{ 'base.css' | asset_url | stylesheet_tag }}
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

`asset_url` resolves to the CDN URL with a cache-busting query string.

### `image_url` filter

```liquid
{{ product.featured_image | image_url: width: 800 }}
{{ image | image_url: width: 800, height: 600, crop: 'center' }}
```

Prefer `image_tag` for full responsive `<img>` markup:

```liquid
{{ image | image_tag: widths: '375,750,1100,1500', sizes: '(min-width: 750px) 50vw, 100vw' }}
```

### `inline_asset_content` filter

For SVG icons rendered inline (no HTTP request, smaller DOM):

```liquid
{{ 'icon-cart.svg' | inline_asset_content }}
```

Pairs well with `<use href="#icon-cart">` spritesheets but is also used for one-off icons.

## SVG icon accessibility (REQUIRED)

Every SVG icon file must include `aria-hidden="true"` on the root `<svg>`:

```svg
<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="none">
  <path d="…"/>
</svg>
```

Icons are decorative. The accessible name comes from the parent interactive element (button / link).
Without `aria-hidden`, screen readers announce the SVG twice or output noise.

## Asset organization patterns

### CSS

- `base.css` — global primitives (variables, typography, focus, animations, utilities, page-width).
- `template-X.css` — template-specific CSS loaded conditionally from the `stylesheets.liquid` snippet.
- Section-specific CSS lives INSIDE the section's `{% stylesheet %}` block — not a separate file (unless
  the rules are too broad to scope, in which case use a `template-X.css`). → `knowledge/languages/css.md`.

### JavaScript

- `global.js` — global behaviours (cart updates, theme editor events, accessibility helpers).
- Component / behaviour JS files (`product-info.js`, `details-modal.js`) — loaded with `defer`.
- Vendor bundles (`swiper-element-bundle.js`, `gsap.js`) — exempt from the minification ban.

### Fonts

Hosted on the Shopify CDN by default via the `font_face` filter. Self-hosted fonts go in `assets/`:

```liquid
@font-face {
  font-family: 'CustomFont';
  src: url('{{ 'custom-font.woff2' | asset_url }}') format('woff2');
  font-display: swap;
}
```

## Theme Store code rules for assets

These apply ONLY for Theme Store submission (private/custom themes are exempt):

- **No Sass / SCSS source files in `assets/`** — assets must be plain CSS. `.scss` files or build
  artefacts in the public assets directory are rejected.
- **No minified first-party CSS / JS** (third-party libs like Swiper are exempt). Reviewers read source.
- **No build system output** — no sourcemaps (`*.map`), `node_modules/`, `package.json`, `package-lock.json`.
- **Protocol-relative URLs** for external CDN references (`//cdn.example.com/...`).

→ Canonical baseline: `knowledge/universal.md` §6 · full requirements: `knowledge/quality/theme-store.md`.

## References

- https://shopify.dev/docs/storefronts/themes/architecture#assets
- https://shopify.dev/docs/api/liquid/filters/asset_url
- https://shopify.dev/docs/api/liquid/filters/image_url
- https://shopify.dev/docs/api/liquid/filters/inline_asset_content
- https://shopify.dev/docs/storefronts/themes/store/requirements
