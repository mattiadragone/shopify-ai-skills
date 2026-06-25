---
title: Sections
summary: Rules for sections/*.liquid and section group JSON — schema, settings, presets, blocks support.
---

# Sections

Rules for `sections/*.liquid` files and section group JSON (`sections/header-group.json`,
`sections/footer-group.json`).

## Anatomy of a section

A section file has up to five parts in this order:

1. Optional `{%- liquid -%}` setup block at the top
2. The rendered markup
3. `{% stylesheet %}` block (section-scoped CSS, Shopify auto-bundles into one `section.css`)
4. `{% javascript %}` block (optional, also auto-bundled)
5. `{% schema %}` block (REQUIRED, JSON only)

```liquid
{%- liquid
  assign heading = section.settings.heading | default: ''
-%}

<section
  class="my-section color-{{ section.settings.color_scheme }}"
  style="--section-padding-top: {{ section.settings.padding_top }}px;"
  {{ section.shopify_attributes }}
>
  <div class="page-width">
    {%- if heading != blank -%}
      <h2 class="my-section__heading">{{ heading }}</h2>
    {%- endif -%}
    {% content_for 'blocks' %}
  </div>
</section>

{% stylesheet %}
  .my-section { padding-top: var(--section-padding-top, 40px); }
{% endstylesheet %}

{% schema %}
{
  "name": "t:names.my_section",
  "tag": "section",
  "class": "section",
  "settings": [],
  "blocks": [{ "type": "@theme" }, { "type": "@app" }],
  "presets": [{ "name": "t:names.my_section" }]
}
{% endschema %}
```

## CSS scoping

Section `{% stylesheet %}` content is bundled into the global `section.css`, loaded on every page —
NOT only when the section renders. Every selector inside MUST start with the section's class (or a
custom-element name unique to the section).

→ Canonical rule: `knowledge/universal.md` §1 · CSS architecture detail: `knowledge/languages/css.md`.

## Schema rules

- `name`: translation key `"t:names.section_name"`; add the key to `locales/en.default.schema.json`.
- `tag`: one of `div`, `section`, `aside`, `header`, `footer`, `main`. Defaults to `div`.
- `class`: applied to the wrapper element. Use it for the section's scope class.
- `settings`: array of input settings. See `knowledge/areas/config.md` for setting types and rules.
- `blocks`: include `{"type":"@theme"}` for theme blocks and `{"type":"@app"}` for app blocks if accepted.
- `presets`: makes the section selectable in the theme editor. Sections without presets can only be used
  via section groups or templates.

### Setting organization (Theme Store conformant)

1. Resource pickers first (`collection`, `product`, `blog`, `page`)
2. Layout (`columns`, spacing)
3. Typography (fonts, sizes)
4. Colors (background, text)
5. Padding / margin last

Group with `{ "type": "header", "content": "..." }` separators.

## Translation keys

Every string visible in the editor (`name`, `label`, `info`, header `content`, preset `name`) MUST be a
translation key. → `knowledge/universal.md` §2 and `knowledge/areas/locales.md`.

## Section groups

`sections/header-group.json` and `sections/footer-group.json` list which sections render in the
header/footer area, with merchant-editable order:

```json
{
  "type": "header",
  "name": "t:names.header",
  "sections": {
    "announcement-bar": { "type": "announcement-bar" },
    "header": { "type": "header" }
  },
  "order": ["announcement-bar", "header"]
}
```

## Common patterns

- **Padding via CSS variables**: emit `--section-padding-top` / `--section-padding-bottom` in the wrapper
  `style` attribute, consume them in the section's CSS.
- **Section-rendered content variations**: use `content_for 'blocks'` for theme blocks,
  `{% content_for 'block', type: 'foo', id: 'bar' %}` for a static-rendered block.
- **App block compatibility**: keep `{"type":"@app"}` in the blocks array for Theme Store eligibility.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/sections
- https://shopify.dev/docs/storefronts/themes/architecture/section-groups
- https://shopify.dev/docs/storefronts/themes/architecture/sections/section-schema
- https://shopify.dev/docs/storefronts/themes/store/requirements
