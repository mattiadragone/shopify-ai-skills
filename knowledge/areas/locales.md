---
title: Locales
summary: Rules for locales/*.json — four file types, storefront vs schema strings, the t: prefix, pluralization, fallback chain.
---

# Locales

Rules for `locales/*.json` — translation keys and the `t:` system.

## The four file types

`locales/` contains four flavors of JSON per language:

- **`<lang>.default.json`** — storefront-facing strings (cart, product, search…) for the default theme
  language. One default per theme. Example: `locales/en.default.json`.
- **`<lang>.json`** — storefront strings for an additional language. Example: `locales/it.json`.
- **`<lang>.default.schema.json`** — merchant-facing strings shown in the theme editor (setting labels,
  section names, info text). One default per theme.
- **`<lang>.schema.json`** — merchant-facing strings for an additional editor language.

Strict rule: storefront strings (`*.json`) and editor strings (`*.schema.json`) are SEPARATE. A key from
`en.default.json` is NOT visible to the editor sidebar; a key from `en.default.schema.json` is NOT
visible in storefront rendering.

## Using translation keys

### Storefront-facing (in Liquid templates)

```liquid
{{ 'cart.general.title' | t }}
{{ 'products.product.add_to_cart' | t }}
```

With dynamic values:

```liquid
{{ 'cart.general.total_count' | t: count: cart.item_count }}
```

```json
{ "cart": { "general": { "total_count": "{{ count }} items in cart" } } }
```

### Merchant-facing (in section / block / config schemas)

Use the `t:` prefix INSIDE JSON values:

```json
{
  "name": "t:names.featured_collection",
  "settings": [
    { "type": "text", "id": "heading", "label": "t:settings.heading",
      "info": "t:settings.heading_info", "default": "Featured collection" }
  ],
  "presets": [ { "name": "t:names.featured_collection" } ]
}
```

Each `t:` key MUST exist in `en.default.schema.json`:

```json
{
  "names": { "featured_collection": "Featured collection" },
  "settings": { "heading": "Heading", "heading_info": "Shown above the collection grid" }
}
```

If a key is missing, the editor displays the raw `t:` string — bad UX and Theme Store rejection.

## File structure

Storefront (`en.default.json`) common top-level keys: `general` (with `accessibility`, `search`,
`social`), `products`, `cart`, `templates`, `sections`, `customer`, `blogs`.

Schema (`en.default.schema.json`) common top level: `names`, `settings`, `settings_schema`, `blocks`.

## Pluralization

```json
{ "cart": { "general": { "item_count": { "one": "{{ count }} item", "other": "{{ count }} items" } } } }
```

```liquid
{{ 'cart.general.item_count' | t: count: cart.item_count }}
```

## Locale fallback chain

Storefront resolution order:

1. Active language file (`<lang>.json`)
2. Default storefront language (`<lang>.default.json`)
3. English fallback (`en.default.json`)
4. Raw key string

If a key is missing in all languages, the storefront shows the raw `cart.general.title` text. Theme Store
reviewers reject themes with raw keys visible.

## Required default keys (Theme Store)

- All storefront text (cart, product, search, account, etc.).
- Every section, block, and theme setting label.
- Accessibility strings (`general.accessibility.*`) for screen readers.

Run `theme-check` with `MissingTemplate` and `TranslationKeyExists` enabled to catch missing keys.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/locales
- https://shopify.dev/docs/api/liquid/filters/translate
- https://shopify.dev/docs/storefronts/themes/markets/multiple-currencies-languages
