# Shopify Theme Skills

A **Claude Code plugin** (`claude-shopify-themes`) for developing and auditing Shopify themes. The project
separates **rules** from **actions**:

- **`knowledge/`** — the rules. One file per Shopify area. Single source of truth. No actions.
- **`skills/`** — the actions. Operation skills that read from `knowledge/` based on the task.

## Architecture

```
.claude-plugin/             PLUGIN manifest + marketplace catalog
├── plugin.json             name (= skill namespace), version, description
└── marketplace.json        lets users add this repo as a marketplace

knowledge/                  RULES — single source of truth
├── universal.md            cross-cutting rules (load for any task)
├── areas/                  sections, snippets, blocks, templates, layout, assets, config, locales
├── languages/              liquid, css, javascript
└── quality/                performance, accessibility, design, theme-store

skills/                     ACTIONS — read from knowledge/
├── shopify-build/          create or modify theme code
├── shopify-audit/          inspect an existing repo (read-only report)
└── shopify-tooling/        CLI, theme-check, Prettier, version control, build pipelines
```

Skills resolve knowledge files via `${CLAUDE_PLUGIN_ROOT}/knowledge/` when installed, or `knowledge/` at
the repo root from a clone.

### The split

`knowledge/` holds *what is true* about Shopify themes — anatomy, rules, examples, thresholds. It never
acts. `skills/` holds *what to do* — each skill is a useful action that loads the relevant knowledge files
and applies them. This removes the duplication that came from every old skill restating the same
cross-cutting rules (CSS bundle pitfall, `t:` prefix, `defer`, etc.).

## The three actions

| Skill | When to invoke |
|---|---|
| **shopify-build** | Creating or modifying any theme file — sections, snippets, blocks, templates, layout, assets, config, locales — or the Liquid/CSS/JS inside them. Includes designing a section/block/layout. |
| **shopify-audit** | Inspecting an existing repo before a merge or Theme Store submission, or diagnosing a Lighthouse/a11y drop. Read-only; runs `shopify theme check` + level-based checks and reports findings with fixes and reasons. |
| **shopify-tooling** | Setting up or running the toolchain — Shopify CLI, theme-check config, Prettier, Theme Inspector, version control, CI, build pipelines. |

Design, optimization, and Theme Store submission are **not** separate skills:

- **Design** → knowledge (`knowledge/quality/design.md`), read by `shopify-build`.
- **Optimize** → `shopify-audit` (find) + `shopify-build` (fix).
- **Submit** → submission level of `shopify-audit` + `knowledge/quality/theme-store.md`.

## How a skill uses knowledge

1. The skill triggers on its `description`.
2. It reads `knowledge/universal.md` first (always).
3. It reads the `knowledge/` files for the file type / concern in play (see the routing table inside each
   `SKILL.md` and in `knowledge/README.md`).
4. It applies the rules — building code, or reporting findings that cite the knowledge file.

## Cross-cutting rules (canonical locations)

- **`{% stylesheet %}` global-bundle pitfall** — canonical in `knowledge/universal.md` §1; authoritative
  detail in `knowledge/languages/css.md`. Area files reference it, they do not repeat it.
- **`t:` prefix** — canonical in `knowledge/universal.md` §2; file-type detail in
  `knowledge/areas/locales.md`.
- **`defer`, `block.shopify_attributes`, image lazy loading, Theme Store code baseline** — all canonical
  in `knowledge/universal.md` (§3–§6).

## How to change or extend

- **Change a rule** → edit the one file in `knowledge/`. Every skill that references it updates for free.
- **Add knowledge** → create a file under `knowledge/areas|languages|quality/`, add it to
  `knowledge/README.md`, and reference it from the relevant skill's routing table.
- **Add an action** → only if it is a genuinely distinct, useful operation. Create
  `skills/shopify-<action>/SKILL.md` with YAML frontmatter (`name`, `description` starting with
  "Use when ..."), a routing section pointing at `knowledge/`, and a procedure. Skills are auto-discovered
  on the next session start.

## Sources

- Skeleton theme: https://github.com/Shopify/skeleton-theme
- Horizon `.cursor/rules` reference: https://github.com/Shopify/horizon/tree/main/.cursor
- Shopify themes docs: https://shopify.dev/docs/storefronts/themes
- Theme Store requirements: https://shopify.dev/docs/storefronts/themes/store/requirements
