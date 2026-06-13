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

## CSS scoping (same pitfall as sections/snippets)

Block `{% stylesheet %}` content goes into the global `section.css` bundle. Every selector inside MUST be scoped to the block class (e.g., `.block-heading`).

## References

- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/quick-start
- https://shopify.dev/docs/storefronts/themes/architecture/blocks/theme-blocks/static-blocks
- https://shopify.dev/docs/storefronts/themes/architecture/blocks
