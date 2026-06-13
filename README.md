# shopify-skills

A collection of AI coding assistant skills for building and maintaining Shopify themes.

Each skill is a focused rule set for a specific area of a Shopify theme — sections, snippets, blocks, Liquid, CSS, JavaScript, performance, accessibility, and more. The skills are written in plain Markdown with YAML frontmatter, making them compatible with any AI tool that supports context files:

| Tool | Convention | How to use |
|---|---|---|
| **Claude Code** | `.claude/skills/` + `SKILL.md` | Auto-discovered on session start via `Skill` tool |
| **Cursor** | `.cursor/rules/` + `.mdc` files | Copy content into rule files |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Paste relevant skill content |
| **Gemini CLI** | `GEMINI.md` | Reference or include skill content |

## Skills included

| Skill | Covers |
|---|---|
| `shopify-sections` | `sections/*.liquid` — schema, structure, presets |
| `shopify-snippets` | `snippets/*.liquid` — LiquidDoc, params, render |
| `shopify-blocks` | `blocks/*.liquid` — theme blocks, static vs dynamic |
| `shopify-templates` | `templates/*.json` + `gift_card.liquid` |
| `shopify-layout` | `layout/theme.liquid` + `password.liquid` |
| `shopify-assets` | `assets/` — asset_url, image_tag, SVG a11y |
| `shopify-config` | `config/settings_schema.json` + `settings_data.json` |
| `shopify-locales` | `locales/` — translation keys, fallback chain |
| `shopify-liquid` | Liquid syntax, tags, filters |
| `shopify-css` | CSS standards, `{% stylesheet %}` scope pitfall |
| `shopify-design` | Design principles, antifragile layouts, merchant UX, dark patterns |
| `shopify-javascript` | JS, Custom Elements, `{% javascript %}` bundle |
| `shopify-theme-store` | Theme Store submission requirements |
| `shopify-accessibility` | WCAG 2.1 AA patterns |
| `shopify-performance` | Lighthouse / Core Web Vitals |
| `shopify-cli-tools` | Shopify CLI, theme-check, Prettier, Inspector |

## Installation

### Claude Code

Clone or copy this repo into your project's `.claude/skills/` directory:

```bash
git clone https://github.com/mattiadragone/shopify-skills .claude/skills/shopify
```

Or add it as a git submodule:

```bash
git submodule add https://github.com/mattiadragone/shopify-skills .claude/skills/shopify
```

Skills are auto-discovered on the next session start.

### Cursor

Copy individual `SKILL.md` files into `.cursor/rules/` renaming them to `.mdc`. Each file's frontmatter `description` field maps to Cursor's rule description.

### Other tools

Each `SKILL.md` is self-contained Markdown. Copy the relevant sections into whatever context file your AI tool reads (`.github/copilot-instructions.md`, `GEMINI.md`, system prompt, etc.).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — Mattia Dragone

## Sources

- [Skeleton theme](https://github.com/Shopify/skeleton-theme)
- [Horizon rules reference](https://github.com/Shopify/horizon/tree/main/.cursor)
- [Shopify themes docs](https://shopify.dev/docs/storefronts/themes)
- [Theme Store requirements](https://shopify.dev/docs/storefronts/themes/store/requirements)
