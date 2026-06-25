---
title: Templates
summary: Rules for templates/*.json and templates/*.liquid — required templates, JSON format, alternates, gift_card.liquid, customer templates.
---

# Templates

Rules for `templates/*.json` and `templates/*.liquid`.

## Required templates (Theme Store)

A Theme Store theme MUST provide:

- `templates/index.json` — home
- `templates/product.json` — default product
- `templates/collection.json` — default collection
- `templates/list-collections.json` — `/collections` index
- `templates/blog.json` — blog index
- `templates/article.json` — single article
- `templates/page.json` — default page
- `templates/cart.json` — cart
- `templates/search.json` — search results
- `templates/404.json` — 404 page
- `templates/password.json` — password page (paired with `layout/password.liquid`)
- `templates/gift_card.liquid` — gift card display (LIQUID, not JSON)
- Customer account templates: `templates/customers/*.liquid` (login, register, account, etc.)

## JSON template format

```json
{
  "sections": {
    "main": { "type": "main-product", "settings": {} },
    "related-products": { "type": "related-products", "settings": {} }
  },
  "order": ["main", "related-products"]
}
```

- `sections` is a map of section ids → section configs.
- Each section entry has a `type` matching a file in `sections/` (without `.liquid`).
- `settings` is optional and overrides section defaults.
- `blocks`, `block_order` are supported when the section defines blocks.
- `order` is the array of section ids in render order.

## Alternate templates

Create `templates/<type>.<suffix>.json` to add a switchable variant:

- `templates/product.featured.json` — selectable in admin via `template_suffix`.
- `templates/page.about.json` — used when a Page has `template_suffix = "about"`.

Detect the suffix in Liquid via `template.suffix` or `template.name`:

```liquid
{%- if template.suffix == 'featured' -%}
  {{ 'template-product-featured.css' | asset_url | stylesheet_tag }}
{%- endif -%}
```

## Customer templates (LIQUID, not JSON)

```
templates/customers/login.liquid
templates/customers/register.liquid
templates/customers/account.liquid
templates/customers/order.liquid
templates/customers/addresses.liquid
templates/customers/activate_account.liquid
templates/customers/reset_password.liquid
```

These pre-date OS 2.0 and stay Liquid for compatibility.

## gift_card.liquid

`templates/gift_card.liquid` is the only top-level Liquid template (not JSON). It renders the gift card
display page with the card code, expiration, and download links. Required for Theme Store.

## Conditional CSS loading per template

The `template` variable is available in `layout/theme.liquid` and snippets. Use it to load
template-scoped CSS:

```liquid
{%- if template contains 'product' -%}
  {{ 'template-product.css' | asset_url | stylesheet_tag }}
{%- endif -%}
{%- if template == 'index' -%}
  {{ 'template-index.css' | asset_url | stylesheet_tag }}
{%- endif -%}
{%- if template.suffix == 'the-skin-edit' -%}
  {{ 'template-blog-the-skin-edit.css' | asset_url | stylesheet_tag }}
{%- endif -%}
```

This is the right place for CSS that is template-specific but too broad to scope in a section's
`{% stylesheet %}` block. See `knowledge/languages/css.md`.

## Section "main-" naming convention

The primary section of a JSON template is named `main-<template>`:

- `templates/product.json` → `sections/main-product.liquid`
- `templates/article.json` → `sections/main-article.liquid`
- `templates/cart.json` → `sections/main-cart-*.liquid` (split across header / items / footer)

These sections typically don't have `presets` because they're meant for a specific template, not general use.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/templates
- https://shopify.dev/docs/storefronts/themes/architecture/templates/json-templates
- https://shopify.dev/docs/storefronts/themes/store/requirements#required-templates
