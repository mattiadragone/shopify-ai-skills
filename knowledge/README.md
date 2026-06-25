# Knowledge base

The **single source of truth** for Shopify theme rules. These files contain *only knowledge* — anatomy,
rules, examples, thresholds, references. They do not perform actions.

The action skills in `../skills/` **read from this folder** based on the operation in progress. When a
rule changes, change it here once; every skill that references it stays correct.

## Layout

```
knowledge/
├── universal.md         Cross-cutting rules — load for ANY theme task. Canonical home for:
│                        CSS global-bundle pitfall, t: prefix, defer, block.shopify_attributes,
│                        image lazy loading, Theme Store code baseline.
│
├── areas/               Theme architecture, one file per file-type
│   ├── sections.md      sections/*.liquid + section groups
│   ├── snippets.md      snippets/*.liquid
│   ├── blocks.md        blocks/*.liquid (theme blocks)
│   ├── templates.md     templates/*.json + gift_card.liquid + customer templates
│   ├── layout.md        layout/theme.liquid + password.liquid
│   ├── assets.md        assets/ — asset_url, image_tag, SVG a11y
│   ├── config.md        config/settings_schema.json + settings_data.json
│   └── locales.md       locales/ — t: keys, fallback chain
│
├── languages/           Code standards, one file per language
│   ├── liquid.md        Liquid syntax, tags, filters
│   ├── css.md           CSS standards + authoritative {% stylesheet %} scoping detail
│   └── javascript.md    JS, Custom Elements, {% javascript %} bundle
│
└── quality/             Cross-cutting quality concerns
    ├── performance.md   Lighthouse, Core Web Vitals
    ├── accessibility.md WCAG 2.1 AA
    ├── design.md        Design principles, merchant + customer UX
    └── theme-store.md   Theme Store submission requirements
```

## Deduplication

Cross-cutting rules live in **`universal.md`** (canonical) and, where deep technical detail is needed, in
the relevant `languages/` file (e.g. CSS scoping detail in `languages/css.md`). Area files **reference**
these instead of repeating them, so there is one place to edit each rule.

## How skills consume it

A skill names the files it needs and reads them. Typical routing:

| Operation | Always load | Plus, by what you touch |
|---|---|---|
| Build a section | `universal.md` | `areas/sections.md`, `languages/css.md`, `areas/locales.md`, `quality/design.md` |
| Build a block | `universal.md` | `areas/blocks.md`, `languages/css.md`, `areas/locales.md` |
| Write CSS | `universal.md` | `languages/css.md`, `quality/performance.md` |
| Audit a repo | `universal.md` | `quality/*` for the "why" behind each finding |

See `../skills/` for the full routing tables.
