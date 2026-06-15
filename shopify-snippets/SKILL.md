---
name: shopify-snippets
description: Use when creating or modifying reusable snippet liquid files in snippets/*.liquid. Covers LiquidDoc documentation, parameter handling with defaults, early returns, render vs include, and the {% stylesheet %} pitfall inside snippets.
---

# Shopify Snippets

## When to invoke

- Creating a new snippet in `snippets/*.liquid`.
- Adding parameters or modifying a snippet's interface.
- Replacing inline duplicated markup with a render call to a snippet.
- Decoding why a snippet is failing silently in production.

## Always pair with

- `shopify-base` — CSS bundle pitfall, t: prefix, defer, lazy loading (mandatory for all theme files)
- `shopify-css` — when the snippet has `{% stylesheet %}` blocks
- `shopify-liquid` — when writing Liquid logic inside the snippet

## Anatomy of a snippet

Snippets are reusable Liquid components called via `{% render 'snippet-name', param: value %}`. Unlike sections, they have NO schema, NO presets, and are not standalone units in the theme editor.

```liquid
{% doc %}
  Renders a product card with customizable image, badge, and CTA.

  @param product {Object} Product object (required)
  @param show_vendor {Boolean} Display vendor name (default: false)
  @param image_ratio {String} 'adapt' | 'square' | 'portrait' (default: 'adapt')
  @param lazy_load {Boolean} Enable lazy image loading (default: true)
  @param card_class {String} Extra classes on the wrapper (default: '')

  @example
    {% render 'product-card',
       product: product,
       show_vendor: true,
       image_ratio: 'square'
    %}
{% enddoc %}

{% liquid
  assign product = product | default: empty
  assign show_vendor = show_vendor | default: false
  assign image_ratio = image_ratio | default: 'adapt'
  assign lazy_load = lazy_load | default: true
  assign card_class = card_class | default: ''

  unless product != empty
    echo '<!-- product-card: missing product param -->'
    break
  endunless
%}

<div class="product-card {{ card_class }}">
  …
</div>
```

## LiquidDoc rules

Every reusable snippet MUST have a `{% doc %}` block. Document:

- Purpose in one line.
- `@param name {Type} description (required | default: x)` for every input.
- `@example` block showing a call.

Snippets without LiquidDoc are caught by `theme-check` (`liquid-free-of-script-tags`, custom rules).

## Parameter defaults

Always set defaults at the top in a single `{% liquid %}` block. Use `| default:` for nil-safety.

Guard required params with `unless / break`. Output an HTML comment on failure — never throw, never partial-render.

## `render` vs `include`

Always use `{% render %}`. `{% include %}` is deprecated:

- `render` uses lexical scoping: caller's vars are NOT visible unless passed explicitly.
- `include` exposes the parent scope — leads to bugs that are hell to debug.

Pass parent variables explicitly via `with` / `as`:

```liquid
{% render 'card', with: product as item %}
```

## CRITICAL: `{% stylesheet %}` inside snippets

Some themes use `{% stylesheet %}` inside snippets. Be aware: Shopify auto-bundles snippet `{% stylesheet %}` blocks into `section.css` (loaded globally). The same scoping pitfall as sections applies.

Rule: CSS inside a snippet's `{% stylesheet %}` block MUST be scoped to a selector unique to that snippet's output (e.g., `.product-card`, `password-modal`, `swiper-container.card-slider__swiper`). Never write top-level rules like `*`, `html`, `body`, `.modal__close-button`, `details[open]`.

If the CSS is truly global, it belongs in `assets/base.css`, not in a snippet stylesheet.

## Performance patterns

- For loops over many items, lift static work out of the loop with `{% liquid %}` + `assign`.
- For image rendering, use the `image_tag` filter with `widths:` and `sizes:` rather than hand-rolling `<img>` markup.
- Use `lazy_load` param to control `loading="lazy"` per-call.

## Icon snippets

Icon snippets (`snippets/icon-*.liquid`) should be plain SVG output. The root `<svg>` MUST include `aria-hidden="true"`:

```liquid
<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
  <path d="…"/>
</svg>
```

Accessible name comes from the interactive element wrapping the icon (button, link), not the icon itself.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/snippets
- https://shopify.dev/docs/storefronts/themes/tools/liquid-prettier-plugin
- https://shopify.dev/docs/api/liquid/tags/render
- https://shopify.dev/docs/storefronts/themes/tools/liquid-doc
