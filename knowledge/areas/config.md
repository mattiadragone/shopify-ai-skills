---
title: Config
summary: Rules for config/settings_schema.json and settings_data.json — setting types, input vs sidebar, color schemes, font picker, visible_if.
---

# Config

Rules for `config/settings_schema.json` (global theme settings UI) and `config/settings_data.json`
(merchant-set values).

## The two files

- **`config/settings_schema.json`** — defines what settings exist and how they render in the theme
  editor sidebar. Edited by the developer.
- **`config/settings_data.json`** — stores the merchant's current values. NEVER hand-edit unless
  migrating between themes (e.g. dev → prod). Otherwise auto-managed by the editor.

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
        "min": 1000, "max": 1600, "step": 100, "unit": "px",
        "default": 1400
      }
    ]
  }
]
```

- First entry MUST be `theme_info` (theme metadata shown to merchants).
- Every other entry is a `category` with a `name` (translation key) and a `settings` array.
- Categories appear as collapsible groups in the editor sidebar.

## Setting types

### Input settings (merchant interacts)

`text`, `textarea`, `richtext`, `inline_richtext`, `html`, `url`, `number`, `range`, `checkbox`,
`select`, `radio`, `color`, `color_background`, `color_scheme`, `color_scheme_group`, `font_picker`,
`image_picker`, `video`, `video_url`, `product`, `product_list`, `collection`, `collection_list`,
`blog`, `article`, `page`, `link_list`, `metaobject`, `metaobject_list`, `liquid` (use sparingly,
security-sensitive), `text_alignment`, `style_layout_panel`.

### Sidebar settings (informational)

- `header` — section heading inside a category
- `paragraph` — explanatory text shown to merchant

These have no `id` and no `default` — presentational only.

## Setting ID rules

- Snake case, lowercase: `^[a-z][a-z0-9_]*$`
- Unique inside its category.
- Used in Liquid as `settings.<id>` (e.g. `settings.page_width`).

## Color scheme groups

Color schemes are defined ONCE in `settings_schema.json`, referenced by sections / blocks via the
`color_scheme` setting type.

```json
{
  "type": "color_scheme_group",
  "id": "color_schemes",
  "definition": [
    { "type": "color", "id": "background", "label": "t:settings.background", "default": "#FFFFFF" },
    { "type": "color", "id": "text", "label": "t:settings.text", "default": "#000000" },
    { "type": "color", "id": "button_bg", "label": "t:settings.button_bg", "default": "#000000" }
  ],
  "role": { "background": "background", "text": "text", "buttons": "button_bg" }
}
```

Theme Store requires at least 4 color schemes, each with matching foreground / background pairs.

## Font picker rules

`default` for `font_picker` uses the format `<family>_<weight><style>`:

- `helvetica_n4` — regular · `helvetica_n7` — bold · `helvetica_i4` — italic · `helvetica_i7` — bold italic

Theme Store requires every font picker to have bold, italic, and bold-italic variants available in the
chosen family.

## visible_if conditional settings

```json
{
  "type": "color",
  "id": "border_color",
  "label": "t:settings.border_color",
  "visible_if": "{{ settings.show_border }}"
}
```

The expression is a Liquid template returning truthy / falsy.

## Translation keys for labels

Every `label`, `info`, `header` `content`, and category `name` MUST be a translation key (`t:...`) in
`locales/en.default.schema.json`. → `knowledge/universal.md` §2 and `knowledge/areas/locales.md`.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/settings/
- https://shopify.dev/docs/storefronts/themes/architecture/settings/input-settings
- https://shopify.dev/docs/storefronts/themes/architecture/settings/sidebar-settings
- https://shopify.dev/docs/storefronts/themes/architecture/config
