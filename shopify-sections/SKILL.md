---
name: shopify-sections
description: Use when creating or modifying section liquid files in sections/*.liquid. Covers required schema structure, settings organization, blocks support, presets, CSS scoping with {% stylesheet %}, translation keys, and Theme Store rules for sections.
---

# Shopify Sections

## When to invoke

- Creating a new section file in `sections/*.liquid`.
- Adding settings, blocks or presets to an existing section.
- Reviewing a section before merging or submitting to the Theme Store.
- Migrating a separate `section-X.css` file into a section's inline `{% stylesheet %}` block.
- Dealing with section group JSON files (`sections/header-group.json`, `sections/footer-group.json`).

## Always pair with

- `shopify-base` — CSS bundle pitfall, t: prefix, defer, lazy loading (mandatory for all theme files)
- `shopify-css` — when the section has `{% stylesheet %}` blocks
- `shopify-liquid` — when writing Liquid logic inside the section
- `shopify-locales` — all schema `label`/`name`/`info` fields require `t:` prefix
- `shopify-blocks` — sections that accept blocks need block schema knowledge

## Anatomy of a section

A section file has up to four parts in this order:

1. Optional `{%- liquid -%}` setup block at the top
2. The rendered markup
3. `{% stylesheet %}` block (section-scoped CSS, Shopify auto-bundles into one section.css)
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

## CRITICAL: `{% stylesheet %}` scoping pitfall

Shopify concatenates all section `{% stylesheet %}` content into ONE `section.css` file loaded **globally on every page**, NOT only when the section is rendered. Selectors with no parent scope leak across the whole site.

❌ **Bad** — bleeds globally:
```css
.modal__close-button { position: absolute; }
details[open] .modal__toggle { position: absolute; }
```

✅ **Good** — scoped to the section:
```css
.my-section .modal__close-button { position: absolute; }
.my-section details[open] .modal__toggle { position: absolute; }
```

Rule: every selector inside `{% stylesheet %}` MUST start with the section's class or a custom-element name unique to the section. If you can't scope it, the CSS belongs in `assets/base.css` or in a `template-*.css` referenced from the layout.

## Schema rules

- `name`: use a translation key `"t:names.section_name"`; add the key to `locales/en.default.schema.json`.
- `tag`: one of `div`, `section`, `aside`, `header`, `footer`, `main`. Defaults to `div`.
- `class`: applied to the wrapper element. Use it for the section's scope class.
- `settings`: array of input settings. See `shopify-config` skill for setting types and rules.
- `blocks`: include `{"type":"@theme"}` for theme blocks and `{"type":"@app"}` for app blocks if the section accepts them.
- `presets`: makes the section selectable in the theme editor. Sections without presets can only be used via section groups or templates.

### Setting organization (Theme Store conformant)

1. Resource pickers first (`collection`, `product`, `blog`, `page`)
2. Layout (`columns`, spacing)
3. Typography (fonts, sizes)
4. Colors (background, text)
5. Padding / margin last

Group with `{ "type": "header", "content": "..." }` separators.

## Translation keys

Every string visible in the editor (`name`, `label`, `info`, header `content`, preset `name`) MUST be a translation key. Add the key to `locales/en.default.schema.json`. See the `shopify-locales` skill for the exact file format.

## Section groups

`sections/header-group.json` and `sections/footer-group.json` are section group files: they list which sections render in the header/footer area, with merchant-editable order. Format:

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

- **Padding via CSS variables**: emit `--section-padding-top` / `--section-padding-bottom` in the wrapper `style` attribute, consume them in the section's CSS.
- **Section-rendered content variations**: use `content_for 'blocks'` for theme blocks, `{% content_for 'block', type: 'foo', id: 'bar' %}` for a static-rendered block.
- **App block compatibility**: keep `{"type":"@app"}` in the blocks array for Theme Store eligibility.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/sections
- https://shopify.dev/docs/storefronts/themes/architecture/section-groups
- https://shopify.dev/docs/storefronts/themes/architecture/sections/section-schema
- https://shopify.dev/docs/storefronts/themes/store/requirements
