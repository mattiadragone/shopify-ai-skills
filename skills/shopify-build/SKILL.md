---
name: shopify-build
description: Use when creating or modifying any Shopify theme code — sections, snippets, blocks, templates, layout, assets, config, locales, or any Liquid/CSS/JS inside them. Routes to the right knowledge files based on which file type you are touching, then writes code that follows them. Also covers designing a section/block/layout (it reads the design principles).
---

# Shopify Build

**Action:** create or edit Shopify theme code that follows every relevant rule.

This skill is a router. It does not contain the rules — it loads them from the knowledge base
(`knowledge/`, at the repo root, sibling of `skills/`) based on what you are building, then applies them.

## When to invoke

- Creating or editing a `sections/`, `snippets/`, `blocks/`, `templates/`, `layout/`, `assets/`,
  `config/`, or `locales/` file.
- Writing or refactoring Liquid, CSS, or JavaScript inside any theme file.
- Designing a new section, block, or layout (reads the design principles before building).
- Optimizing existing code for performance or accessibility (reads those quality files, then edits).

## How to use the knowledge base

1. **Always** read `knowledge/universal.md` first — the cross-cutting rules that apply to every file.
2. Then read the files in the routing table below for the file type(s) you are touching.
3. Write code that conforms. If a rule references another file (e.g. CSS scoping → `languages/css.md`),
   read that too when it's relevant.

If you can't locate the repo root, Glob for `knowledge/universal.md` and resolve paths from there.

## Routing table — what to load for what you touch

| You are touching | Read (after `universal.md`) |
|---|---|
| `sections/*.liquid` or section groups | `areas/sections.md` + `languages/css.md` + `areas/locales.md` + `quality/design.md` |
| `snippets/*.liquid` | `areas/snippets.md` + `languages/css.md` + `languages/liquid.md` |
| `blocks/*.liquid` | `areas/blocks.md` + `languages/css.md` + `areas/locales.md` + `quality/design.md` |
| `templates/*.json` / `gift_card.liquid` | `areas/templates.md` + `areas/sections.md` |
| `layout/theme.liquid` / `password.liquid` | `areas/layout.md` + `languages/css.md` + `languages/javascript.md` |
| `assets/*.css` | `languages/css.md` + `quality/performance.md` |
| `assets/*.js` | `languages/javascript.md` + `quality/performance.md` + `quality/accessibility.md` |
| `assets/` images / fonts / SVG | `areas/assets.md` + `quality/performance.md` |
| `config/settings_schema.json` | `areas/config.md` + `areas/locales.md` |
| `locales/*.json` | `areas/locales.md` |
| any Liquid logic | `languages/liquid.md` |
| building accessible interactive UI | `quality/accessibility.md` + `languages/javascript.md` |
| performance-sensitive work | `quality/performance.md` |

Pick every row that applies. Building a section with a slider, for example, loads `sections`, `css`,
`locales`, `design`, plus `javascript`, `accessibility`, and `performance`.

## Procedure

1. Identify the file type(s) the task touches.
2. Load `universal.md` + the matching knowledge files.
3. Build or edit the code so it satisfies those rules — especially the high-frequency traps:
   scope every `{% stylesheet %}` selector, `t:`-prefix every schema string, `defer` scripts,
   `block.shopify_attributes` on block roots, lazy-load + dimension images.
4. Self-check against the rules you loaded before finishing. To run the linter or verify in a store, hand
   off to `shopify-tooling`; to inspect the whole repo for regressions, hand off to `shopify-audit`.

## Example prompts

- "Create a hero section with a heading, subheading, image, and CTA button."
- "Add a testimonials block that nests inside the existing reviews section."
- "Refactor `snippets/product-card.liquid` to use `image_tag` with responsive widths."
- "Build a collection template with filtering and a product grid section."
- "Add a 'page width' setting to the theme settings and wire it into base.css."
- "Make the cart drawer keyboard-accessible with focus trapping."

## References

- Knowledge base index: `knowledge/README.md`
- https://shopify.dev/docs/storefronts/themes
