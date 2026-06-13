---
name: shopify-cli-tools
description: Use when working with Shopify CLI commands (shopify theme dev/pull/push/check), theme-check linter, Liquid Prettier plugin, Theme Inspector for Chrome, or setting up local dev for a Shopify theme repo. Covers init, dev preview, push/pull, environments, theme-check config, and the .shopifyignore pattern.
---

# Shopify CLI & Tools

## When to invoke

- Setting up local dev for a new clone of a Shopify theme repo.
- Pulling settings_data.json from production or pushing changes to a dev theme.
- Running theme-check before commit.
- Debugging `shopify theme dev` (preview server) errors.
- Configuring `.shopifyignore` to keep extraneous files out of pushes.

## Prerequisites

- Node.js LTS (≥ 18 recommended).
- Shopify CLI (Ruby version 2.x is deprecated — use the Node CLI).

Install:
```bash
npm install -g @shopify/cli @shopify/theme
shopify version
```

Authenticate to a store the first time you run a command:
```bash
shopify theme dev --store mystore.myshopify.com
```

A browser opens for OAuth login. Subsequent commands use the cached token.

## Core commands

### `shopify theme init`

Scaffolds a new theme from skeleton-theme or Dawn:
```bash
shopify theme init my-theme
shopify theme init my-theme --clone-url https://github.com/Shopify/horizon
```

### `shopify theme dev`

Starts a local preview server with hot reload:
```bash
shopify theme dev
shopify theme dev --store mystore.myshopify.com
shopify theme dev --theme-editor-sync
```

- Opens `http://127.0.0.1:9292` (configurable).
- File changes auto-sync to a hidden development theme on the store.
- `--theme-editor-sync` syncs theme editor changes back to the local files.

Press `t` in the terminal to open the storefront preview, `e` for the editor.

### `shopify theme push`

Upload local files to a theme on the store:
```bash
shopify theme push                              # interactive theme picker
shopify theme push --theme 123456789            # by theme id
shopify theme push --unpublished --json         # create new unpublished theme, machine-readable output
shopify theme push --only sections/main-product.liquid templates/product.json
shopify theme push --ignore assets/*.scss
```

CRITICAL: `--live` pushes to the published theme. NEVER run this on a production store without explicit approval.

### `shopify theme pull`

Download files from a theme to local:
```bash
shopify theme pull --theme 123456789 --only templates config locales
```

Useful for grabbing `config/settings_data.json` after merchants have edited settings in the admin.

### `shopify theme list`

```bash
shopify theme list
```

Lists all themes on the store with their ids and roles (live, unpublished, development).

### `shopify theme check`

Runs the theme linter on the current directory:
```bash
shopify theme check
shopify theme check --auto-correct
shopify theme check --fail-level error
```

See `.theme-check.yml` config below.

### `shopify theme console`

Liquid REPL against the store's runtime context:
```bash
shopify theme console
> {{ shop.name }}
```

Useful for testing filters / objects without round-tripping a render.

## Environments and credentials

For multi-store / multi-env workflows, create a `shopify.theme.toml`:

```toml
[environments.production]
store = "mystore.myshopify.com"
theme = "123456789"

[environments.staging]
store = "mystore-staging.myshopify.com"
theme = "987654321"
unpublished = true
```

Then:
```bash
shopify theme dev -e staging
shopify theme push -e production --live
```

## `.shopifyignore`

Like `.gitignore`, but for files NOT to push / pull:

```
# Dev artefacts
node_modules/
.git/
.github/

# Build output (if you use a build system)
src/
build/
*.scss
*.scss.map

# CLI temp files (Shopify CLI sometimes creates these on push)
.shopify/
.shopifyignore.bak

# Local config
.theme-check.yml
shopify.theme.toml
```

`.shopifyignore` patterns are checked at push / pull time. Glob patterns supported (Bash-style).

## Theme Check

CLI-based linter. Configure via `.theme-check.yml` at the repo root:

```yaml
extends: theme-check:recommended

# Disable checks that don't fit your theme
RemoteAsset:
  enabled: false

# Customize severity
UnusedAssign:
  enabled: true
  severity: warning

# Ignore specific files
ignore:
  - "vendor/**/*"
  - "assets/legacy-*.css"
```

Common checks:

- `MissingTemplate` — referenced section / snippet doesn't exist.
- `UnusedAssign` — declared variable never used.
- `LiquidTag` — invalid tag.
- `MatchingTranslations` — missing translation key in non-default locales.
- `ParserBlockingScript` — script in `<head>` without `defer` / `async`.
- `RemoteAsset` — externally hosted asset (slows down LCP).
- `ImgWidthAndHeight` — `<img>` missing width / height (CLS).
- `AssetSizeAppBlockCSS` — section CSS bundle exceeds size threshold.

Run on every PR via GitHub Action (https://github.com/Shopify/theme-check-action).

## Liquid Prettier plugin

Install:
```bash
npm install --save-dev prettier @shopify/prettier-plugin-liquid
```

`.prettierrc`:
```json
{
  "plugins": ["@shopify/prettier-plugin-liquid"],
  "overrides": [
    { "files": "*.liquid", "options": { "parser": "liquid-html" } }
  ]
}
```

Run:
```bash
npx prettier --write 'sections/**/*.liquid' 'snippets/**/*.liquid' 'blocks/**/*.liquid' 'layout/**/*.liquid'
```

Use the Shopify Liquid VS Code extension for editor integration (format on save, syntax highlighting, completion, theme-check inline).

## Shopify Theme Inspector for Chrome

https://chromewebstore.google.com/detail/shopify-theme-inspector-f/fndnankcflemoafdeboboehphmiijkgp

Adds a Liquid tab in Chrome DevTools showing:

- Liquid render time per section.
- Top slowest tags and filters.
- Cache hit / miss for fragments.

Essential for diagnosing slow templates (especially product / collection with many products).

## Lighthouse CI

GitHub Action: https://github.com/Shopify/lighthouse-ci-action

```yaml
- uses: shopify/lighthouse-ci-action@v1
  with:
    store: ${{ secrets.STORE }}
    password: ${{ secrets.STORE_PASSWORD }}
    pull_theme: ${{ steps.pull-request-theme.outputs.theme-id }}
```

Run Lighthouse on every PR with the preview theme as target. Fails the build if perf < 60 or a11y < 90.

## GitHub integration

https://shopify.dev/docs/storefronts/themes/tools/github

Connect a GitHub repo to a Shopify theme:

- Pushing to a branch auto-syncs to the corresponding theme.
- Theme editor changes auto-commit back to the branch.

Pattern: `main` branch ↔ `Live` theme; feature branches ↔ unpublished themes for preview.

## Common workflows

### "Pull merchant edits before merging"

```bash
shopify theme pull --theme PROD_THEME_ID --only config locales
git add config locales
git commit -m "chore: pull merchant edits from production"
```

### "Deploy a feature branch as a preview theme"

```bash
shopify theme push --unpublished --json | tee theme-info.json
# theme-info.json includes preview URL — share with PMs / reviewers
```

### "Run theme-check + Prettier in CI"

```yaml
- run: npx prettier --check 'sections/**/*.liquid' 'snippets/**/*.liquid'
- run: shopify theme check --fail-level error
```

## References

- https://shopify.dev/docs/api/shopify-cli
- https://shopify.dev/docs/api/shopify-cli/theme
- https://shopify.dev/docs/storefronts/themes/tools/theme-check
- https://shopify.dev/docs/storefronts/themes/tools/liquid-prettier-plugin
- https://shopify.dev/docs/storefronts/themes/tools/theme-inspector
- https://shopify.dev/docs/storefronts/themes/tools/github
- https://shopify.dev/docs/storefronts/themes/tools
