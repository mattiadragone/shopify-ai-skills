# Shopify Theme Skills

A set of AI skills for developing and auditing Shopify themes. Skills are auto-loaded by Claude Code and other tools that read `.claude/skills/`. Each skill is invoked by name when its trigger conditions match the task.

## Architecture — three layers

```
BASE LAYER     shopify-base         (always load alongside every build skill)
BUILD LAYER    shopify-sections, shopify-snippets, shopify-blocks, shopify-templates,
               shopify-layout, shopify-assets, shopify-config, shopify-locales,
               shopify-liquid, shopify-css, shopify-javascript, shopify-performance,
               shopify-accessibility, shopify-theme-store, shopify-design, shopify-tooling
AUDIT LAYER    shopify-audit-critical, shopify-audit-quality, shopify-audit-submission
```

**Base layer**: universal rules (CSS bundle pitfall, `t:` prefix, `defer`, `block.shopify_attributes`, lazy loading). Load with every build task.

**Build layer**: file-type or concern-specific rules. Each skill lists which other skills to pair with it in an `## Always pair with` section.

**Audit layer**: diagnostic commands that inspect an existing repo without writing code. Use in audit mode, not while building.

## Layout

```
.claude/
├── skills/
│   ├── shopify-base/              # Universal rules — load with every build skill
│   │
│   ├── shopify-sections/          # sections/*.liquid
│   ├── shopify-snippets/          # snippets/*.liquid
│   ├── shopify-blocks/            # blocks/*.liquid
│   ├── shopify-templates/         # templates/*.json + gift_card.liquid
│   ├── shopify-layout/            # layout/theme.liquid + password.liquid
│   ├── shopify-assets/            # assets/ — asset_url, image_tag, SVG a11y
│   ├── shopify-config/            # config/settings_schema.json
│   ├── shopify-locales/           # locales/ — t: keys, fallback chain
│   │
│   ├── shopify-liquid/            # Liquid syntax, tags, filters
│   ├── shopify-css/               # CSS standards, {% stylesheet %} scope pitfall
│   ├── shopify-javascript/        # JS, Custom Elements, {% javascript %} bundle
│   │
│   ├── shopify-theme-store/       # Theme Store submission requirements
│   ├── shopify-accessibility/     # WCAG 2.1 AA, component patterns
│   ├── shopify-performance/       # Lighthouse, CWV, image lazy loading
│   ├── shopify-design/            # Design principles, antifragile layouts, merchant UX
│   ├── shopify-tooling/           # Shopify CLI, theme-check, Prettier, version control
│   │
│   ├── shopify-audit-critical/    # Blocking error checks (CSS scoping, t: prefix, etc.)
│   ├── shopify-audit-quality/     # Performance/a11y quality checks
│   └── shopify-audit-submission/  # Theme Store compliance checklist
│
├── commands/
│   ├── shopify-audit.md           # /shopify-audit — full 3-layer audit
│   └── shopify-build.md           # /shopify-build <file> — build with correct skills
│
└── hooks/                         # optional project-specific automation
```

## Build mode — skill trigger map

### Base (always load first)

| Skill | When to invoke |
|---|---|
| **shopify-base** | With ANY Shopify theme task, alongside every other build skill |

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

### Quality & compliance

| Skill | When to invoke |
|---|---|
| **shopify-theme-store** | Auditing for Theme Store submission or checking Theme Store eligibility |
| **shopify-accessibility** | Building or auditing accessible UI (WCAG 2.1 AA) |
| **shopify-performance** | Lighthouse / Core Web Vitals optimization |
| **shopify-design** | Designing sections, blocks, or full theme layouts |

### Tooling

| Skill | When to invoke |
|---|---|
| **shopify-tooling** | Shopify CLI, theme-check, Prettier, Theme Inspector, version control, build tools |

## Audit mode — skill trigger map

Audit skills inspect an existing repo. They run shell commands and report findings — they do not write code.

| Skill | When to invoke |
|---|---|
| **shopify-audit-critical** | Pre-merge or pre-submission check for blocking errors |
| **shopify-audit-quality** | Investigating Lighthouse score drops or a11y failures |
| **shopify-audit-submission** | Full Theme Store submission compliance checklist |

## Cross-cutting topics

### `{% stylesheet %}` global-bundle pitfall

Shopify bundles ALL `{% stylesheet %}` content from sections / blocks / snippets into ONE `section.css` loaded on every page. Unscoped selectors leak globally. This is the most critical cross-cutting rule. Covered in:

- `shopify-base` — the canonical rule statement.
- `shopify-css` — scope rules, where each kind of CSS belongs.
- `shopify-sections`, `shopify-snippets`, `shopify-blocks` — file-specific guidance.
- `shopify-audit-critical` — grep command to detect scoping leaks in existing code.

### Translation keys (`t:` prefix)

Every visible string must be a translation key. Covered in:

- `shopify-base` — the canonical `t:` prefix rule.
- `shopify-locales` — file types and lookup chain.
- `shopify-sections`, `shopify-blocks`, `shopify-config` — `t:` prefix in schemas.
- `shopify-accessibility` — a11y strings (`general.accessibility.*`).
- `shopify-audit-critical` — grep command to detect missing `t:` prefixes.

### Theme Store rules

- `shopify-theme-store` — canonical reference for all submission requirements.
- `shopify-css`, `shopify-javascript`, `shopify-assets` — no-Sass / no-minified / native-CSS rules.
- `shopify-accessibility` — Lighthouse a11y ≥ 90 threshold.
- `shopify-performance` — Lighthouse performance ≥ 60 threshold.
- `shopify-audit-submission` — full pre-submission checklist with shell commands.

## Sources

- Skeleton theme: https://github.com/Shopify/skeleton-theme
- Horizon `.cursor/rules` reference: https://github.com/Shopify/horizon/tree/main/.cursor
- Shopify themes docs: https://shopify.dev/docs/storefronts/themes
- Theme Store requirements: https://shopify.dev/docs/storefronts/themes/store/requirements

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

   ## Always pair with
   - `shopify-base` — universal rules (mandatory for all theme files)
   - `other-skill` — reason why

   ## References
   - https://shopify.dev/...
   ```
3. Add a row to the trigger map above.
4. The skill is auto-discovered the next time Claude Code starts.
