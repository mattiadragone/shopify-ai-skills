---
name: shopify-layout
description: Use when modifying layout/theme.liquid or layout/password.liquid. Covers the <head> structure, content_for_header/layout/footer hooks, conditional CSS/JS loading via snippets, the password layout, and the section group rendering pattern.
---

# Shopify Layouts

## When to invoke

- Editing the `<head>` of the theme (meta tags, scripts, link tags).
- Adding or removing global CSS / JS files.
- Working on `layout/password.liquid` (separate from `theme.liquid`).
- Wiring section groups for header / footer.

## Always pair with

- `shopify-base` — universal rules (mandatory for all theme files)
- `shopify-css` — global CSS is loaded from layout; conditional loading pattern matters
- `shopify-javascript` — global JS is loaded from layout; defer order matters
- `shopify-sections` — section groups (`header-group.json`, `footer-group.json`) are wired here

## The two layouts

- `layout/theme.liquid` — wraps every storefront page (product, collection, cart, etc.).
- `layout/password.liquid` — wraps the password page only. Used automatically when the store is password-protected.

Each layout MUST contain:

- `{{ content_for_header }}` inside `<head>` (Shopify injects analytics, app scripts, etc.).
- `{{ content_for_layout }}` in the body (the actual template content).
- (Optional) section group references for header / footer.

## Basic structure

```liquid
<!doctype html>
<html lang="{{ request.locale.iso_code }}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="canonical" href="{{ canonical_url }}">

    <title>{{ page_title }}</title>
    {%- if page_description -%}
      <meta name="description" content="{{ page_description | escape }}">
    {%- endif -%}

    {%- render 'meta-tags' -%}
    {%- render 'stylesheets' -%}
    {%- render 'scripts' -%}

    {{ content_for_header }}
  </head>

  <body class="template-{{ template.name }}">
    {% sections 'header-group' %}
    <main role="main">
      {{ content_for_layout }}
    </main>
    {% sections 'footer-group' %}
  </body>
</html>
```

## Section groups in layouts

`{% sections 'header-group' %}` renders the section group defined in `sections/header-group.json`. The Theme Store REQUIRES header and footer to be section groups (not hardcoded section calls), so merchants can reorder / replace them.

## CSS loading pattern

Don't dump `<link>` tags inline. Centralize in a `snippets/stylesheets.liquid` snippet rendered from the layout. Inside that snippet:

```liquid
{{ 'base.css' | asset_url | stylesheet_tag }}

{%- if template contains 'product' -%}
  {{ 'template-product.css' | asset_url | stylesheet_tag }}
{%- endif -%}
{%- if template contains 'collection' -%}
  {{ 'template-collection.css' | asset_url | stylesheet_tag }}
{%- endif -%}
{%- if template.suffix == 'special-blog' -%}
  {{ 'template-special-blog.css' | asset_url | stylesheet_tag }}
{%- endif -%}
```

Conditional `template`-scoped CSS is loaded only on matching templates. See the `shopify-templates` skill for which conditions to use.

## password.liquid quirks

`layout/password.liquid` is a SEPARATE layout. It does NOT render the same `stylesheets.liquid` and `header-group` as `theme.liquid` automatically. If you have password-specific CSS, load it from `layout/password.liquid` directly:

```liquid
{{ 'base.css' | asset_url | stylesheet_tag }}
{{ 'template-password.css' | asset_url | stylesheet_tag }}
```

CRITICAL: do NOT dump password-page-only CSS into a section's `{% stylesheet %}` block. Shopify bundles all section stylesheets into one global `section.css` loaded everywhere, and unscoped rules (`html`, `body`, `*`, `.modal__toggle`) will leak into the storefront and break unrelated pages (e.g., the search icon on the home page being a `<summary class="modal__toggle">` will inherit `position: absolute` and disappear). Put template-wide CSS in a `template-password.css` file referenced from `layout/password.liquid`.

## JavaScript loading in layouts

Defer everything that isn't critical:

```liquid
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

Deferred scripts execute in document order AFTER HTML parsing, BEFORE `DOMContentLoaded`. Inline `{% javascript %}` blocks in sections run in the same defer batch.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/layouts
- https://shopify.dev/docs/storefronts/themes/architecture/section-groups
- https://shopify.dev/docs/api/liquid/objects/content_for_layout
