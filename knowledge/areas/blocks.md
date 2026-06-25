---
title: Theme blocks
summary: Rules for blocks/*.liquid — theme blocks, static vs dynamic, schema, presets, @theme/@app accept-lists, granularity.
---

# Theme blocks

Rules for `blocks/*.liquid`.

## Theme blocks vs section-level blocks

- **Section-level blocks**: declared inline inside a section's `{% schema %}` `blocks` array. Old style,
  limited reuse.
- **Theme blocks** (`blocks/*.liquid`): standalone block files reusable across multiple sections and
  nestable inside other theme blocks. Modern approach (OS 2.0+).

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

## `block.shopify_attributes` (mandatory)

Always render `{{ block.shopify_attributes }}` on the block's root element, or it is not selectable in
the editor. → Canonical rule: `knowledge/universal.md` §4.

## Static vs dynamic blocks

- **Dynamic** (`{% content_for 'blocks' %}` in a parent section/block): merchant chooses which blocks to
  add. Order is merchant-controlled.
- **Static** (`{% content_for 'block', type: 'heading', id: 'main-heading' %}`): the theme dev
  hard-renders a specific block at a specific place (e.g. a product card always has a price block). Still
  configurable in the editor, but its presence and position are not removable.

## Schema for theme blocks

- No `tag` or `class` at the schema root (section-only).
- `name` is the block's editor label.
- `settings`, `blocks`, `presets` work the same as sections.
- A block can declare its OWN `blocks` array to allow nesting.

## Accept-list pattern in sections

```json
"blocks": [
  { "type": "@theme" },        // accept any theme block
  { "type": "@app" },          // accept any app block (required for Theme Store)
  { "type": "_product-info" }  // accept only this specific private block
]
```

Underscore-prefixed types (`_name`) are private to that section — not available globally as theme blocks.

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

Don't split closely related attributes into separate blocks. Group them into a single block that makes
sense as a unit.

- **Wrong — too granular:** Block: Author name · Block: Post date · Block: Comment count
- **Right — grouped:** Block: Post meta (author, date, comment count as settings)

The test: if a merchant would never add one without the other, they belong in the same block.

### Block layout rules

- **Vertical stacking**: text-based content where hierarchy matters (heading → subheading → body).
- **Horizontal / adaptive grid**: peers with no hierarchy (features grid, icon list).
- Blocks must reflow correctly across breakpoints — don't assume a minimum block count or fixed columns.
- **Don't rely on block order for layout logic.** Block order is merchant-controlled. A section must look
  professional with any sequence and any combination of accepted block types.

### When to use app blocks

Before adding `{ "type": "@app" }`, evaluate:

- **Clear use case**: an obvious reason a merchant would add an app here? Product info → reviews/loyalty
  — yes. Hero banner — probably not.
- **Layout resilience**: does the layout hold up if an unexpected app block is inserted?
- **CSS edge cases**: avoid `@app` if it requires excessive conditional CSS to handle unknown shapes.
- **Purpose clarity**: if `@app` makes the section's purpose ambiguous, reconsider.

## Metafields and dynamic sources

### Reference metafields via dynamic sources

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

For structured metafield types (rating, volume, dimension, file), build dedicated blocks:

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

## CSS scoping

Block `{% stylesheet %}` content goes into the global `section.css` bundle. Every selector inside MUST be
scoped to the block class (e.g. `.block-heading`). → `knowledge/universal.md` §1 · `knowledge/languages/css.md`.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/quick-start
- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/static-blocks
- https://shopify.dev/docs/storefronts/themes/architecture/blocks
