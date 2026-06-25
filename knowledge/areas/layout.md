---
title: Layout
summary: Rules for layout/theme.liquid and layout/password.liquid — head structure, content_for hooks, section groups, CSS/JS loading.
---

# Layout

Rules for `layout/theme.liquid` and `layout/password.liquid`.

## The two layouts

- `layout/theme.liquid` — wraps every storefront page (product, collection, cart, etc.).
- `layout/password.liquid` — wraps the password page only. Used automatically when the store is
  password-protected.

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

`{% sections 'header-group' %}` renders the section group defined in `sections/header-group.json`. The
Theme Store REQUIRES header and footer to be section groups (not hardcoded section calls), so merchants
can reorder / replace them.

## CSS loading pattern

Don't dump `<link>` tags inline. Centralize in a `snippets/stylesheets.liquid` snippet rendered from the
layout:

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

Conditional `template`-scoped CSS loads only on matching templates. See `knowledge/areas/templates.md`.

## password.liquid quirks

`layout/password.liquid` is a SEPARATE layout. It does NOT render the same `stylesheets.liquid` and
`header-group` as `theme.liquid` automatically. Load password-specific CSS directly from it:

```liquid
{{ 'base.css' | asset_url | stylesheet_tag }}
{{ 'template-password.css' | asset_url | stylesheet_tag }}
```

CRITICAL: do NOT dump password-page-only CSS into a section's `{% stylesheet %}` block. Unscoped rules
(`html`, `body`, `*`, `.modal__toggle`) leak into the storefront via the global `section.css` and break
unrelated pages (e.g. a `<summary class="modal__toggle">` search icon inheriting `position: absolute`
and disappearing). Put template-wide CSS in `template-password.css` referenced from the layout.
→ `knowledge/universal.md` §1.

## JavaScript loading in layouts

Defer everything that isn't critical:

```liquid
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
```

Deferred scripts execute in document order AFTER HTML parsing, BEFORE `DOMContentLoaded`. Inline
`{% javascript %}` blocks run in the same defer batch. See `knowledge/languages/javascript.md`.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/layouts
- https://shopify.dev/docs/storefronts/themes/architecture/section-groups
- https://shopify.dev/docs/api/liquid/objects/content_for_layout
