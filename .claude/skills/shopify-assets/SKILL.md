---
name: shopify-assets
description: Use when adding, removing, or referencing files in the assets/ directory. Covers the flat-directory constraint, asset_url and inline_asset_content filters, SVG icon a11y rules, image optimization with image_tag, and the no-Sass/no-minified-output Theme Store rule.
---

# Shopify Assets

## When to invoke

- Adding a new file to `assets/` (CSS, JS, image, font, SVG icon).
- Referencing an asset from a Liquid file.
- Deciding whether something should go in `assets/` or as inline output.
- Cleaning up unused asset files.

## Always pair with

- `shopify-base` — universal rules (mandatory for all theme files)
- `shopify-performance` — image optimization, lazy loading, and bundle size audit live here

## The flat-directory rule

`assets/` is **flat** — no subdirectories. Every file lives at the top of `assets/`. This is enforced by Shopify and cannot be changed.

Naming conventions to compensate:

- `component-X.css`, `section-X.css`, `template-X.css` (legacy/Dawn).
- `template-product.css`, `template-collection.css`, `template-blog-the-skin-edit.css` (template-scoped).
- `icon-arrow.svg`, `icon-cart.svg` (icons).

## Referencing assets

### `asset_url` filter

For files included via `<link>` or `<script>`:

```liquid
{{ 'base.css' | asset_url | stylesheet_tag }}
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

`asset_url` resolves to the CDN URL with cache-busting query string.

### `image_url` filter

For images that need responsive sizing:

```liquid
{{ product.featured_image | image_url: width: 800 }}
{{ image | image_url: width: 800, height: 600, crop: 'center' }}
```

Prefer the `image_tag` filter for full responsive `<img>` markup:

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

Every SVG icon file in `assets/` must include `aria-hidden="true"` on the root `<svg>` element:

```svg
<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="none">
  <path d="…"/>
</svg>
```

Reason: icons are decorative. The accessible name comes from the parent interactive element (button / link) — not the icon. Without `aria-hidden`, screen readers announce the SVG twice or output noise.

## Theme Store code rules for assets

- **No Sass / SCSS source files in `assets/`** — assets must be plain CSS. Sass output is allowed, but Theme Store reviewers will reject submissions with `.scss` files or build artefacts in the public assets directory.
- **No minified CSS / JS files** for first-party theme code (third-party libs like Swiper are exempt). Theme Store reviewers want to read the source.
- **No build system output** like sourcemaps (`*.map`), `node_modules/`, `package.json`, `package-lock.json` should be tracked.
- **Protocol-relative URLs** for external CDN references (`//cdn.example.com/...`).

These rules apply ONLY for Theme Store submission. Private/custom themes can do whatever.

## Asset organization patterns

### CSS

- `base.css` — global primitives (variables, typography, focus, animations, utilities, page-width).
- `template-X.css` — template-specific CSS loaded conditionally from `stylesheets.liquid` snippet.
- Section-specific CSS lives INSIDE the section's `{% stylesheet %}` block — not as a separate file (unless the rules are too broad to scope, in which case use a `template-X.css`).

### JavaScript

- `global.js` — global behaviours (cart updates, theme editor events, accessibility helpers).
- Component / behaviour JS files (`product-info.js`, `details-modal.js`, `predictive-search.js`) — loaded with `defer`.
- Vendor bundles (`swiper-element-bundle.js`, `gsap.js`) — exempt from minification ban.

### Fonts

Hosted on the Shopify CDN by default via `font_face` filter. Self-hosted fonts go in `assets/`:

```liquid
@font-face {
  font-family: 'CustomFont';
  src: url('{{ 'custom-font.woff2' | asset_url }}') format('woff2');
  font-display: swap;
}
```

## References

- https://shopify.dev/docs/storefronts/themes/architecture#assets
- https://shopify.dev/docs/api/liquid/filters/asset_url
- https://shopify.dev/docs/api/liquid/filters/image_url
- https://shopify.dev/docs/api/liquid/filters/inline_asset_content
- https://shopify.dev/docs/storefronts/themes/store/requirements
