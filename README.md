# Shopify Theme Skills

A set of agent skills for developing and maintaining Shopify themes. Skills are auto-loaded by Claude Code and other tools that read `.claude/skills/`. Each skill is invoked by name when its trigger conditions match a task.

Structure inspired by Horizon's `.cursor/rules` and `.claude/skills/` layout, adapted as Claude Code skills (single `SKILL.md` per directory with YAML frontmatter).

## Layout

```
.claude/skills/
├── shopify-sections/              # sections/*.liquid — section schema, structure, presets
├── shopify-snippets/              # snippets/*.liquid — LiquidDoc, params, render
├── shopify-blocks/                # blocks/*.liquid — theme blocks, static vs dynamic
├── shopify-templates/             # templates/*.json + gift_card.liquid
├── shopify-layout/                # layout/theme.liquid + password.liquid
├── shopify-assets/                # assets/ — flat dir, asset_url, image_tag, SVG a11y
├── shopify-config/                # config/settings_schema.json + settings_data.json
├── shopify-locales/               # locales/ — t: keys, fallback chain
│
├── shopify-liquid/                # Liquid syntax, tags, filters, render
├── shopify-css/                   # CSS standards, {% stylesheet %} scope pitfall
├── shopify-javascript/            # JS, Custom Elements, {% javascript %} bundle
│
├── shopify-theme-store/           # Theme Store submission requirements
├── shopify-accessibility/         # WCAG 2.1 AA, component patterns
├── shopify-performance/           # Lighthouse, CWV, image lazy loading
│
└── shopify-cli-tools/             # Shopify CLI, theme-check, Prettier, Inspector
```

## Areas

### Architecture (file types)

| Skill | When to invoke |
|---|---|
| **shopify-sections** | Creating / modifying a `sections/*.liquid` file or section group JSON |
| **shopify-snippets** | Creating / modifying a `snippets/*.liquid` reusable component |
| **shopify-blocks** | Creating / modifying a theme block in `blocks/*.liquid` |
| **shopify-templates** | Working with `templates/*.json` or `templates/gift_card.liquid` |
| **shopify-layout** | Editing `layout/theme.liquid` or `layout/password.liquid` |
| **shopify-assets** | Adding / referencing files in `assets/` |
| **shopify-config** | Modifying `config/settings_schema.json` (UI) or `settings_data.json` (values) |
| **shopify-locales** | Adding / modifying translation keys in `locales/*.json` |

### Code standards

| Skill | When to invoke |
|---|---|
| **shopify-liquid** | Writing or debugging Liquid in any `.liquid` file |
| **shopify-css** | CSS in `assets/*.css` or in `{% stylesheet %}` blocks |
| **shopify-javascript** | JS in `assets/*.js` or in `{% javascript %}` blocks |

### Compliance & quality

| Skill | When to invoke |
|---|---|
| **shopify-theme-store** | Auditing for Theme Store submission |
| **shopify-accessibility** | Building or auditing accessible UI (WCAG 2.1 AA) |
| **shopify-performance** | Lighthouse / CWV optimization |

### Workflow & tooling

| Skill | When to invoke |
|---|---|
| **shopify-cli-tools** | Shopify CLI, theme-check, Prettier, Theme Inspector |

## Cross-cutting topics (look across multiple skills)

### `{% stylesheet %}` global-bundle pitfall

Shopify bundles ALL `{% stylesheet %}` content from sections / blocks / snippets into ONE `section.css` loaded on every page. Unscoped selectors leak globally. Covered in:

- `shopify-css` — the core pitfall and scope rules.
- `shopify-sections`, `shopify-snippets`, `shopify-blocks` — file-specific guidance.
- `shopify-layout` — when to lift CSS out into a `template-X.css` loaded from the layout instead.

### Translation keys

Every visible string must be a translation key. Covered in:

- `shopify-locales` — file types and lookup chain.
- `shopify-sections`, `shopify-blocks`, `shopify-config` — `t:` prefix in schemas.
- `shopify-accessibility` — a11y strings (`general.accessibility.*`).

### Theme Store rules

- `shopify-theme-store` is the canonical reference.
- `shopify-css`, `shopify-javascript`, `shopify-assets` enforce the no-Sass / no-minified / native-CSS rules.
- `shopify-accessibility` and `shopify-performance` enforce the Lighthouse thresholds.

## Sources

- Skeleton theme structure: https://github.com/Shopify/skeleton-theme
- Horizon `.cursor/rules` reference: https://github.com/Shopify/horizon/tree/main/.cursor
- Shopify themes docs: https://shopify.dev/docs/storefronts/themes
- Theme Store requirements: https://shopify.dev/docs/storefronts/themes/store/requirements
- Theme tools overview: https://shopify.dev/docs/storefronts/themes/tools

## How to add a new skill

1. Create a directory under `.claude/skills/<skill-name>/`.
2. Add a `SKILL.md` with YAML frontmatter:
   ```markdown
   ---
   name: skill-name
   description: One-line description starting with "Use when ..."
   ---

   # Skill Title

   ## When to invoke
   ...

   ## References
   - https://shopify.dev/...
   ```
3. Add a row to the table above.
4. The skill is auto-discovered the next time Claude Code starts.
