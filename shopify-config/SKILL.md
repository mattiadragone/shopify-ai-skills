---
name: shopify-config
description: Use when modifying config/settings_schema.json (global theme settings UI) or config/settings_data.json (merchant-set values). Covers setting types, input vs sidebar settings, color schemes, font picker, and the difference between schema and data files.
---

# Shopify Theme Config

## When to invoke

- Adding a new global theme setting (logo, brand color, default font, layout width, etc.).
- Modifying the settings sidebar UI in the theme editor.
- Reading or migrating `settings_data.json` between themes.
- Adding a color scheme group.

## Always pair with

- `shopify-base` — universal rules (mandatory for all theme files)
- `shopify-locales` — every `label`, `info`, and `name` in settings_schema must be a `t:` key

## The two files

- **`config/settings_schema.json`** — defines what settings exist and how they render in the theme editor sidebar. Edited by the developer.
- **`config/settings_data.json`** — stores the merchant's current values for each setting. NEVER hand-edit unless migrating between themes.

`settings_data.json` is auto-managed by the editor. The only time you touch it manually is when porting settings between two themes (e.g., dev → prod).

## settings_schema.json structure

```json
[
  {
    "name": "theme_info",
    "theme_name": "My Theme",
    "theme_version": "1.0.0",
    "theme_author": "Studio Name",
    "theme_documentation_url": "https://example.com/docs",
    "theme_support_url": "https://example.com/support"
  },
  {
    "name": "t:settings_schema.layout.name",
    "settings": [
      {
        "type": "range",
        "id": "page_width",
        "label": "t:settings_schema.layout.page_width.label",
        "min": 1000,
        "max": 1600,
        "step": 100,
        "unit": "px",
        "default": 1400
      }
    ]
  }
]
```

- First entry MUST be `theme_info`. It defines the theme metadata shown to merchants.
- Every other entry is a `category` with a `name` (translation key) and a `settings` array.
- Categories appear as collapsible groups in the editor sidebar.

## Setting types

### Input settings (merchant interacts)

- `text` — single-line text
- `textarea` — multi-line text
- `richtext` — rich text editor (HTML allowed)
- `inline_richtext` — inline rich text (limited HTML)
- `html` — raw HTML input
- `url` — URL with picker for products / collections / pages
- `number` — numeric input
- `range` — slider with min / max / step / unit
- `checkbox` — boolean
- `select` — dropdown with options array
- `radio` — radio buttons with options array
- `color` — single color picker
- `color_background` — CSS background (color, gradient, or image)
- `color_scheme` — references a color scheme group
- `color_scheme_group` — defines a group of color schemes (only in settings_schema)
- `font_picker` — Shopify font picker (use `default: 'helvetica_n4'` or similar)
- `image_picker` — merchant uploads or picks an image
- `video` — merchant picks a Shopify-hosted video
- `video_url` — YouTube / Vimeo URL
- `product` — single product picker
- `product_list` — multi-product picker
- `collection` — single collection picker
- `collection_list` — multi-collection picker
- `blog` — single blog picker
- `article` — single article picker
- `page` — single page picker
- `link_list` — navigation menu picker
- `metaobject` — single metaobject reference
- `metaobject_list` — multi-metaobject reference
- `liquid` — raw Liquid input (use sparingly, security-sensitive)
- `text_alignment` — left / center / right
- `style_layout_panel` — layout panel editor

### Sidebar settings (informational)

- `header` — section heading inside a category
- `paragraph` — explanatory text shown to merchant

These have no `id` and no `default` — they're presentational only.

## Setting ID rules

- Snake case, lowercase: `^[a-z][a-z0-9_]*$`
- Must be unique inside its category.
- Used in Liquid as `settings.<id>` (e.g., `settings.page_width`).

## Color scheme groups

Color schemes are special: defined ONCE in `settings_schema.json`, referenced by sections / blocks via `color_scheme` setting type.

```json
{
  "type": "color_scheme_group",
  "id": "color_schemes",
  "definition": [
    { "type": "color", "id": "background", "label": "t:settings.background", "default": "#FFFFFF" },
    { "type": "color", "id": "text", "label": "t:settings.text", "default": "#000000" },
    { "type": "color", "id": "button_bg", "label": "t:settings.button_bg", "default": "#000000" }
  ],
  "role": {
    "background": "background",
    "text": "text",
    "buttons": "button_bg"
  }
}
```

Theme Store requires at least 4 color schemes, each with matching foreground / background pairs.

## Font picker rules

`default` for `font_picker` settings uses the format `<family>_<weight><style>`:

- `helvetica_n4` — Helvetica regular
- `helvetica_n7` — Helvetica bold
- `helvetica_i4` — Helvetica italic
- `helvetica_i7` — Helvetica bold italic

Theme Store requires every font picker to have bold, italic, and bold-italic variants available in the chosen font family.

## Translation keys for labels

Every `label`, `info`, `header` `content`, and category `name` MUST be a translation key (`t:...`). Add the key to `locales/en.default.schema.json`. See the `shopify-locales` skill.

## visible_if conditional settings

A setting can be hidden conditionally:

```json
{
  "type": "color",
  "id": "border_color",
  "label": "t:settings.border_color",
  "visible_if": "{{ settings.show_border }}"
}
```

The expression is a Liquid template returning truthy / falsy.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/settings/
- https://shopify.dev/docs/storefronts/themes/architecture/settings/input-settings
- https://shopify.dev/docs/storefronts/themes/architecture/settings/sidebar-settings
- https://shopify.dev/docs/storefronts/themes/architecture/config
