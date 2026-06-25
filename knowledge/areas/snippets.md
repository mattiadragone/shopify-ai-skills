---
title: Snippets
summary: Rules for snippets/*.liquid reusable components — LiquidDoc, parameters, render vs include, icon a11y.
---

# Snippets

Rules for `snippets/*.liquid` — reusable Liquid components called via
`{% render 'snippet-name', param: value %}`. Unlike sections they have NO schema, NO presets, and are
not standalone units in the theme editor.

## Anatomy of a snippet

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

## Parameter defaults

Always set defaults at the top in a single `{% liquid %}` block. Use `| default:` for nil-safety.
Guard required params with `unless / break`. Output an HTML comment on failure — never throw, never
partial-render.

## `render` vs `include`

Always use `{% render %}`. `{% include %}` is deprecated:

- `render` uses lexical scoping: caller's vars are NOT visible unless passed explicitly.
- `include` exposes the parent scope — leads to bugs that are hell to debug.

Pass parent variables explicitly via `with` / `as`:

```liquid
{% render 'card', with: product as item %}
```

## CSS scoping inside snippets

Shopify auto-bundles snippet `{% stylesheet %}` blocks into the global `section.css`. CSS inside a
snippet's `{% stylesheet %}` block MUST be scoped to a selector unique to that snippet's output
(e.g. `.product-card`, `password-modal`). If the CSS is truly global, it belongs in `assets/base.css`.

→ Canonical rule: `knowledge/universal.md` §1 · CSS architecture detail: `knowledge/languages/css.md`.

## Performance patterns

- For loops over many items, lift static work out of the loop with `{% liquid %}` + `assign`.
- For image rendering, use the `image_tag` filter with `widths:` and `sizes:` rather than hand-rolling
  `<img>` markup.
- Use a `lazy_load` param to control `loading="lazy"` per-call.

## Icon snippets

Icon snippets (`snippets/icon-*.liquid`) should be plain SVG output. The root `<svg>` MUST include
`aria-hidden="true"`:

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
