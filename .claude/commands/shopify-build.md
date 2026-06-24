---
description: Build or modify a Shopify theme file. Loads shopify-base plus the appropriate file-type skill based on the target path or task description.
---

The user wants to build or modify a Shopify theme file: $ARGUMENTS

**Step 1 — identify target file type** from the argument or from context:

| Target | Skills to load |
|---|---|
| `sections/*.liquid` | `shopify-base` + `shopify-sections` + `shopify-liquid` |
| `snippets/*.liquid` | `shopify-base` + `shopify-snippets` + `shopify-liquid` |
| `blocks/*.liquid` | `shopify-base` + `shopify-blocks` + `shopify-liquid` |
| `templates/*.json` | `shopify-base` + `shopify-templates` |
| `layout/theme.liquid` | `shopify-base` + `shopify-layout` + `shopify-liquid` |
| `assets/*.css` | `shopify-base` + `shopify-css` |
| `assets/*.js` | `shopify-base` + `shopify-javascript` |
| `config/settings_schema.json` | `shopify-base` + `shopify-config` |
| `locales/*.json` | `shopify-base` + `shopify-locales` |

If the argument doesn't specify a file type, ask the user which file they are working on before proceeding.

**Step 2 — load identified skills** from `.claude/skills/`, then implement the requested change following all loaded skill rules.

Always load `shopify-base` first.
