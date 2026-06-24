---
name: shopify-blocks
description: Use when creating or modifying theme blocks in blocks/*.liquid. Covers theme blocks (reusable, nestable), static vs dynamic blocks, schema, settings, presets within parent sections, and the @theme/@app block accept-list pattern.
---

# Shopify Theme Blocks

## When to invoke

- Creating a new block in `blocks/*.liquid`.
- Adding a block to a section's `blocks` schema array.
- Nesting blocks inside other blocks (theme block composition).
- Migrating section-level blocks (`{ "type": "...", "settings": [] }` inside the section schema) to standalone theme blocks.

## Always pair with

- `shopify-base` — CSS bundle pitfall, t: prefix, block.shopify_attributes, lazy loading (mandatory)
- `shopify-css` — when the block has `{% stylesheet %}` blocks
- `shopify-liquid` — when writing Liquid logic inside the block
- `shopify-locales` — all schema `label`/`name`/`info` fields require `t:` prefix
- `shopify-sections` — blocks always live within sections; section schema governs what blocks are accepted

## Theme blocks vs section-level blocks

There are two block systems in Shopify themes:

- **Section-level blocks**: declared inline inside a section's `{% schema %}` `blocks` array. Old style, limited reuse.
- **Theme blocks** (`blocks/*.liquid`): standalone block files that can be reused across multiple sections and nested inside other theme blocks. This is the modern approach (OS 2.0+).

Prefer theme blocks. The Theme Store requires sections to support theme blocks via `{ "type": "@theme" }`.

## Anatomy of a theme block

```liquid
{% doc %}
  Renders a configurable heading block.

  @example
  {% content_for 'block', type: 'heading', id: 'heading-1' %}
{% enddoc %}

<div
  {{ block.shopify_attributes }}
  class="block-heading"
  style="--heading-size: {{ block.settings.size }}px;"
>
  <h{{ block.settings.level }}>
    {{ block.settings.text }}
  </h{{ block.settings.level }}>
</div>

{% stylesheet %}
  .block-heading h1,
  .block-heading h2,
  .block-heading h3 { font-size: var(--heading-size, 32px); }
{% endstylesheet %}

{% schema %}
{
  "name": "t:names.heading",
  "settings": [
    { "type": "text", "id": "text", "label": "t:settings.text", "default": "Heading" },
    { "type": "select", "id": "level", "label": "t:settings.level",
      "options": [
        { "value": "1", "label": "H1" }, { "value": "2", "label": "H2" }, { "value": "3", "label": "H3" }
      ],
      "default": "2"
    }
  ],
  "presets": [{ "name": "t:names.heading" }]
}
{% endschema %}
```

## Critical: `block.shopify_attributes`

Always render `{{ block.shopify_attributes }}` on the block's root element. Without it, the block is not selectable in the theme editor.

## Static vs dynamic blocks

- **Dynamic** (`{% content_for 'blocks' %}` in a parent section/block): merchant chooses which blocks to add. Order is merchant-controlled.
- **Static** (`{% content_for 'block', type: 'heading', id: 'main-heading' %}`): the theme dev hard-renders a specific block at a specific place. Useful for guaranteeing structural blocks (e.g., a product card always has a price block).

Static blocks still appear in the editor for merchant configuration, but their presence and position are not removable.

## Schema for theme blocks

- No `tag` or `class` at the schema root (those are section-only).
- `name` is the block's editor label.
- `settings`, `blocks`, `presets` work the same as sections.
- A block can declare its OWN `blocks` array to allow nesting.

## Accept-list pattern in sections

A section's schema declares which blocks it accepts:

```json
"blocks": [
  { "type": "@theme" },     // accept any theme block
  { "type": "@app" },       // accept any app block (required for Theme Store)
  { "type": "_product-info" }  // accept only this specific private block
]
```

Underscore-prefixed types (`_name`) are private to that section: not available globally as theme blocks.

## Preset with nested blocks

When a block contains other blocks, presets must specify `block_order`:

```json
{
  "blocks": {
    "header": {
      "type": "group",
      "blocks": {
        "title": { "type": "heading" },
        "price": { "type": "price" }
      },
      "block_order": ["title", "price"]
    }
  },
  "block_order": ["header"]
}
```

## Block granularity

### Avoid over-granular blocks

Don't split closely related attributes into separate blocks. Group them into a single block that makes sense as a unit.

**Wrong — too granular:**
- Block: Author name
- Block: Post date
- Block: Comment count

**Right — grouped:**
- Block: Post meta (author, date, comment count as settings)

The test: if a merchant would never add one without the other, they belong in the same block.

### Block layout rules

- **Vertical stacking**: use for text-based content where hierarchy matters (heading → subheading → body).
- **Horizontal / adaptive grid**: use when blocks are peers with no hierarchy (features grid, icon list).
- Blocks must reflow correctly across breakpoints — don't assume a minimum block count or fixed column count.
- **Don't rely on block order for layout logic.** Block order is merchant-controlled. A section must look professional with any sequence and any combination of accepted block types.

### When to use app blocks

Before adding `{ "type": "@app" }` to a section's accept list, evaluate:

- **Clear use case**: is there an obvious reason a merchant would add an app here? Product info → reviews app, loyalty badges — yes. Hero banner — probably not.
- **Layout resilience**: does the layout hold up if an unexpected app block is inserted? If it breaks, don't offer `@app`.
- **CSS edge cases**: avoid `@app` support if it requires excessive conditional CSS to handle unknown block shapes.
- **Purpose clarity**: if `@app` makes the section's purpose ambiguous, reconsider.

## Metafields and dynamic sources

### Reference metafields via dynamic sources

Use dynamic sources in block settings to let merchants bind metafield values without hardcoding them:

```json
{
  "type": "text",
  "id": "custom_label",
  "label": "t:settings.custom_label",
  "default": "",
  "dynamic_sources": true
}
```

Merchants can then select a metafield as the source directly in the theme editor.

### Build metafield-specific blocks

For structured metafield types (rating, volume, dimension, file), build dedicated blocks that render the metafield correctly:

```liquid
{%- comment -%} blocks/product-rating.liquid {%- endcomment -%}
<div class="block-rating" {{ block.shopify_attributes }}>
  {%- assign rating = product.metafields.reviews.rating.value -%}
  {%- if rating -%}
    <span class="rating-value">{{ rating.rating }}</span>
    <span class="rating-scale">/ {{ rating.scale_max }}</span>
  {%- endif -%}
</div>
```

Audit common metafield namespaces for your target segment and build blocks for the ones merchants in that space commonly use.

## CSS scoping (same pitfall as sections/snippets)

Block `{% stylesheet %}` content goes into the global `section.css` bundle. Every selector inside MUST be scoped to the block class (e.g., `.block-heading`).

## References

- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/quick-start
- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/static-blocks
- https://shopify.dev/docs/storefronts/themes/architecture/blocks
