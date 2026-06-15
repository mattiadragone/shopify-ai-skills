# shopify-ai-skills

A collection of AI coding assistant skills for building and auditing Shopify themes.

Each skill is a focused rule set for a specific area of a Shopify theme. Skills are plain Markdown files with YAML frontmatter — compatible with any AI tool that supports context files.

| Tool | Convention | How to use |
|---|---|---|
| **Claude Code** | `.claude/skills/` + `SKILL.md` | Auto-discovered via `Skill` tool |
| **Cursor** | `.cursor/rules/` + `.mdc` files | Copy content into rule files |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Paste relevant skill content |
| **Gemini CLI** | `GEMINI.md` | Reference or include skill content |

---

## Architecture

Skills are organized in three layers that work together:

```
┌────────────────────────────────────────────────────────────────┐
│  AUDIT LAYER (inspect existing repos)                          │
│  shopify-audit-critical  shopify-audit-quality                 │
│  shopify-audit-submission                                      │
├────────────────────────────────────────────────────────────────┤
│  BUILD LAYER (create or edit theme code)                       │
│  shopify-sections   shopify-snippets   shopify-blocks          │
│  shopify-templates  shopify-layout     shopify-assets          │
│  shopify-config     shopify-locales    shopify-liquid          │
│  shopify-css        shopify-javascript shopify-performance     │
│  shopify-accessibility  shopify-theme-store  shopify-design    │
│  shopify-tooling                                               │
├────────────────────────────────────────────────────────────────┤
│  BASE LAYER (always loaded with every build skill)             │
│  shopify-base                                                  │
└────────────────────────────────────────────────────────────────┘
```

### Base layer

`shopify-base` contains universal rules that apply to every Shopify theme file:

- `{% stylesheet %}` global bundle pitfall — the most critical cross-cutting rule
- `t:` prefix mandatory in all schema strings
- `defer` on all scripts
- `block.shopify_attributes` on every block root element
- Images require `loading="lazy"` and explicit `width`/`height`
- Theme Store code baseline

Load `shopify-base` alongside every other build skill. It is never useful alone.

### Build layer

Build skills guide code creation for specific file types. Each skill includes an **Always pair with** section listing which other skills should be loaded alongside it — because working on one file type almost always affects another (CSS scoping, t: keys, performance).

### Audit layer

Audit skills run diagnostic checks against an existing repo without writing any code. They contain shell commands, grep patterns, and severity-ordered checklists that surface errors before a review or Theme Store submission.

---

## Build mode — which skills to use

Load `shopify-base` + the skills matching what you are working on:

| Task | Load these skills |
|---|---|
| Create or edit a section | `shopify-base` + `shopify-sections` + `shopify-css` + `shopify-locales` |
| Create or edit a block | `shopify-base` + `shopify-blocks` + `shopify-css` + `shopify-locales` |
| Create or edit a snippet | `shopify-base` + `shopify-snippets` + `shopify-css` + `shopify-liquid` |
| Edit `layout/theme.liquid` | `shopify-base` + `shopify-layout` + `shopify-css` + `shopify-javascript` |
| Edit JSON templates | `shopify-base` + `shopify-templates` + `shopify-sections` |
| Write Liquid logic | `shopify-base` + `shopify-liquid` |
| Write CSS | `shopify-base` + `shopify-css` + `shopify-performance` |
| Write JavaScript | `shopify-base` + `shopify-javascript` + `shopify-performance` + `shopify-accessibility` |
| Performance optimization | `shopify-base` + `shopify-performance` + `shopify-javascript` + `shopify-css` |
| Accessibility fixes | `shopify-base` + `shopify-accessibility` + `shopify-javascript` + `shopify-css` |
| Design layout / UX | `shopify-base` + `shopify-design` + `shopify-accessibility` + `shopify-performance` |
| Theme Store prep | `shopify-base` + `shopify-theme-store` + `shopify-accessibility` + `shopify-performance` |
| Tooling / CLI / version control | `shopify-tooling` |

---

## Audit mode — which skills to use

Run audit skills against an existing repo. No code is written — only inspection.

| Audit goal | Load this skill |
|---|---|
| Check for blocking errors before merge | `shopify-audit-critical` |
| Check Lighthouse / performance / a11y quality | `shopify-audit-quality` |
| Prepare for Theme Store submission | `shopify-audit-submission` |
| Full pre-submission review | All three audit skills, in order |

---

## Skills reference

### Base

| Skill | Covers |
|---|---|
| `shopify-base` | Universal rules for all theme files: CSS bundle pitfall, `t:` prefix, `defer`, `block.shopify_attributes`, lazy loading, code baseline |

### Build

| Skill | Covers |
|---|---|
| `shopify-sections` | `sections/*.liquid` — schema, settings, presets, section groups |
| `shopify-snippets` | `snippets/*.liquid` — LiquidDoc, params, render vs include |
| `shopify-blocks` | `blocks/*.liquid` — theme blocks, static vs dynamic, `@theme`/`@app` accept-lists |
| `shopify-templates` | `templates/*.json` + `gift_card.liquid` — required templates, JSON format, alternates |
| `shopify-layout` | `layout/theme.liquid` + `password.liquid` — head structure, section groups, CSS/JS loading |
| `shopify-assets` | `assets/` — flat directory, `asset_url`, `image_tag`, SVG a11y, Theme Store code rules |
| `shopify-config` | `config/settings_schema.json` — setting types, color schemes, font pickers |
| `shopify-locales` | `locales/` — translation keys, fallback chain, storefront vs schema files |
| `shopify-liquid` | Liquid syntax — tags, filters, `{% liquid %}` block, `render` vs `include` |
| `shopify-css` | CSS — `{% stylesheet %}` scoping, custom properties, page-width grid, conditional loading |
| `shopify-javascript` | JS — Custom Elements, `{% javascript %}` bundle, editor events, defer order, pubsub |
| `shopify-performance` | Lighthouse / Core Web Vitals — images, fonts, JS bundle size, Liquid loops |
| `shopify-accessibility` | WCAG 2.1 AA — focus management, ARIA, keyboard, color contrast, touch targets |
| `shopify-theme-store` | Theme Store requirements — all thresholds, compliance rules, submission checklist |
| `shopify-design` | Design principles — antifragile layouts, merchant UX, dark patterns, empty states |
| `shopify-tooling` | Shopify CLI, `theme-check`, Prettier, Theme Inspector, version control, build tools |

### Audit

| Skill | Covers |
|---|---|
| `shopify-audit-critical` | Blocking errors: CSS scoping leaks, `t:` prefix, `block.shopify_attributes`, undeferred scripts, missing alt, `theme-check` |
| `shopify-audit-quality` | Performance/a11y: Lighthouse scores, JS bundle size, preload count, touch targets, focus indicators, lazy loading |
| `shopify-audit-submission` | Theme Store compliance: required templates, section groups, `@app`/`@theme` blocks, code rules, color schemes, Partner Program |

---

## Installation

### Claude Code

Clone this repo into your project's `.claude/skills/` directory:

```bash
git clone https://github.com/mattiadragone/shopify-ai-skills .claude/skills/shopify
```

Or add it as a git submodule:

```bash
git submodule add https://github.com/mattiadragone/shopify-ai-skills .claude/skills/shopify
```

Skills are auto-discovered on the next session start. The AI picks up skills by name when the task matches their `description` field.

### Cursor

Copy individual `SKILL.md` files into `.cursor/rules/`, renaming them to `.mdc`. Each file's frontmatter `description` field maps to Cursor's rule description. To always load the base layer, copy `shopify-base/SKILL.md` as `shopify-base.mdc` and set it to apply globally.

### GitHub Copilot

Paste relevant skill content into `.github/copilot-instructions.md`. Include the base layer at the top, followed by the build skills relevant to your project.

### Gemini CLI

Add skill content to `GEMINI.md` or reference it via `@file` in your prompt. The base layer should always be included.

### Other tools

Each `SKILL.md` is self-contained Markdown. Copy the relevant sections into whatever context file your AI tool reads (system prompt, project rules, etc.).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — Mattia Dragone

## Sources

- [Skeleton theme](https://github.com/Shopify/skeleton-theme)
- [Horizon rules reference](https://github.com/Shopify/horizon/tree/main/.cursor)
- [Shopify themes docs](https://shopify.dev/docs/storefronts/themes)
- [Theme Store requirements](https://shopify.dev/docs/storefronts/themes/store/requirements)
