---
name: shopify-tooling
description: Use when setting up or running the Shopify theme dev toolchain — Shopify CLI (dev/push/pull/check), theme-check linter config, Liquid Prettier, Theme Inspector, version control strategy, CI/CD, and build pipelines (SCSS, PostCSS, JS bundling, JIT). The action skill for "set this up / run this for me", not for writing theme code.
---

# Shopify Tooling

**Action:** set up and run the theme development workflow — CLI, linting, formatting, version control,
CI, and build pipelines.

For writing theme code, use `shopify-build`; to inspect a repo, use `shopify-audit`. This skill owns the
commands and configuration around them.

## When to invoke

- Setting up local dev for a new theme repo.
- Running, pushing, or pulling themes with Shopify CLI.
- Configuring CI/CD for a theme project.
- Choosing a version control strategy (source vs compiled code).
- Setting up a build pipeline (SCSS, PostCSS, JS bundling) or evaluating JIT.
- Running theme-check or Prettier.

---

## Shopify CLI

### Install

```bash
npm install -g @shopify/cli @shopify/theme
shopify version
```

First run opens a browser for OAuth; subsequent commands use the cached token.

### Core commands

| Command | Purpose |
|---|---|
| `shopify theme init` | Scaffold from skeleton-theme or Dawn |
| `shopify theme dev` | Local preview server with hot reload |
| `shopify theme push` | Upload local files to a store theme |
| `shopify theme pull` | Download files from a store theme |
| `shopify theme list` | List all themes with ids and roles |
| `shopify theme check` | Run the linter |
| `shopify theme console` | Liquid REPL against live store context |

### `shopify theme dev`

```bash
shopify theme dev --store mystore.myshopify.com
shopify theme dev --theme-editor-sync   # sync editor changes back to local files
```

Opens `http://127.0.0.1:9292`. Press `t` for the storefront preview, `e` for the editor.

### `shopify theme push`

```bash
shopify theme push                                        # interactive picker
shopify theme push --theme 123456789                      # by id
shopify theme push --unpublished --json                   # create new unpublished, machine-readable
shopify theme push --only sections/main-product.liquid    # partial push
shopify theme push --ignore assets/*.scss                 # exclude files
```

`--live` pushes to the published theme. **Never run on production without explicit approval.**

### `shopify theme pull`

```bash
shopify theme pull --theme 123456789 --only templates config locales
```

Useful for grabbing `config/settings_data.json` after merchant edits in the admin.

### Multi-environment config (`shopify.theme.toml`)

```toml
[environments.production]
store = "mystore.myshopify.com"
theme = "123456789"

[environments.staging]
store = "mystore-staging.myshopify.com"
theme = "987654321"
unpublished = true
```

```bash
shopify theme dev -e staging
shopify theme push -e production
```

### `.shopifyignore`

```
node_modules/
.git/
.github/
src/
build/
*.scss
*.scss.map
.shopify/
shopify.theme.toml
```

---

## theme-check

Configure via `.theme-check.yml`:

```yaml
extends: theme-check:recommended
RemoteAsset:
  enabled: false
UnusedAssign:
  enabled: true
  severity: warning
ignore:
  - "vendor/**/*"
```

Key checks: `ParserBlockingScript`, `ImgWidthAndHeight`, `TranslationKeyExists`, `MissingTemplate`,
`RemoteAsset`, `AssetSizeAppBlockCSS`.

```bash
shopify theme check
shopify theme check --auto-correct
shopify theme check --fail-level error   # non-zero exit on errors (CI)
```

CI: `- uses: Shopify/theme-check-action@v2`. (For full repo inspection beyond the linter, use
`shopify-audit`.)

## Liquid Prettier

```bash
npm install --save-dev prettier @shopify/prettier-plugin-liquid
```

`.prettierrc`:
```json
{
  "plugins": ["@shopify/prettier-plugin-liquid"],
  "overrides": [{ "files": "*.liquid", "options": { "parser": "liquid-html" } }]
}
```

```bash
npx prettier --write 'sections/**/*.liquid' 'snippets/**/*.liquid' 'blocks/**/*.liquid'
```

## Shopify Theme Inspector for Chrome

Liquid tab in DevTools showing render time per section, slowest tags, cache hits. Essential for
diagnosing slow templates. → `knowledge/quality/performance.md`.

## Lighthouse CI

```yaml
- uses: Shopify/lighthouse-ci-action@v1
  with:
    store: ${{ secrets.STORE }}
    password: ${{ secrets.STORE_PASSWORD }}
    pull_theme: ${{ steps.theme.outputs.theme-id }}
```

Fails the build if performance < 60 or accessibility < 90.

---

## Version control

### Branch strategy

Connect `main` directly to the live Shopify theme via the GitHub integration. Use non-main branches for
campaign/seasonal themes. For build pipelines: keep `main` as source, maintain a `deploy` branch with
compiled output connected to Shopify.

```
main (source)  →  [CI builds]  →  deploy (compiled)  →  Shopify store
```

### Four source/compiled strategies

| Strategy | Recommended? | Notes |
|---|---|---|
| Branch separation (git subtree) | **Yes** | Single repo, clean history, GitHub-integration compatible |
| Separate repositories | OK | Easy start, extra maintenance |
| Mixed (source + compiled together) | Avoid | Merchants may edit compiled files |
| Source-only (no GitHub integration) | OK | Manual push only |

```bash
git subtree push --prefix dist origin deploy
```

### Critical constraint

Branches connected to Shopify must match the default theme folder structure at root (`assets/`,
`sections/`, etc.). No `src/dist` at root.

### Merchant customization risk

Merchants can edit compiled files in the Shopify admin code editor; rebuilding from source overwrites
those edits. Use the GitHub commit history from the Shopify integration to identify merchant changes
before rebuilding.

---

## Build tools

### JIT vs build pipeline

Shopify auto-minifies CSS and JS on upload. Prefer JIT if you only need minification — no pipeline, no
backfilling risk. Add a pipeline only when you need SCSS, PostCSS/Tailwind, JS bundling, SVG snippets, or
critical CSS inlining.

| Need | Tool |
|---|---|
| SCSS → CSS | Dart Sass (`sass` CLI) |
| PostCSS / Autoprefixer | PostCSS CLI |
| JS bundling | esbuild |
| Tailwind | Tailwind CLI or PostCSS plugin |
| Task runner | npm scripts |

```bash
sass src/scss/base.scss assets/base.css --style=expanded --no-source-map
esbuild src/js/theme.js --bundle --outfile=assets/theme.js --format=esm
```

Do NOT minify first-party output — Shopify auto-minifies, and minified first-party files violate Theme
Store rules. JS entry-point target: ≤ 16 KB minified. → `knowledge/quality/theme-store.md`,
`knowledge/quality/performance.md`.

### Tailwind config for Liquid

```js
// tailwind.config.js
module.exports = {
  content: [
    './layout/**/*.liquid', './sections/**/*.liquid', './snippets/**/*.liquid',
    './blocks/**/*.liquid', './templates/**/*.liquid',
  ],
};
```

### SVGs as snippets

```bash
for f in src/icons/*.svg; do
  name=$(basename "$f" .svg)
  cp "$f" "snippets/icon-${name}.liquid"
done
```

---

## Common workflows

### Pull merchant edits before merging

```bash
shopify theme pull --theme PROD_THEME_ID --only config locales
git add config locales && git commit -m "chore: pull merchant edits"
```

### Deploy feature branch as preview theme

```bash
shopify theme push --unpublished --json | tee theme-info.json
# preview URL in theme-info.json — share with reviewers
```

### CI pipeline (theme-check + Prettier + Lighthouse)

```yaml
- run: npx prettier --check 'sections/**/*.liquid'
- run: shopify theme check --fail-level error
- uses: Shopify/lighthouse-ci-action@v1
```

## Example prompts

- "Set up Shopify CLI and start a local dev server for my store."
- "Add a theme-check config and a CI workflow that fails on errors."
- "Configure Prettier for Liquid and format all sections."
- "Set up a source/deploy branch strategy with a SCSS build."

## References

- https://shopify.dev/docs/api/shopify-cli/theme
- https://shopify.dev/docs/storefronts/themes/tools/theme-check
- https://shopify.dev/docs/storefronts/themes/tools/liquid-prettier-plugin
- https://shopify.dev/docs/storefronts/themes/tools/theme-inspector
- https://shopify.dev/docs/storefronts/themes/tools/github
- https://shopify.dev/docs/storefronts/themes/best-practices/version-control
- https://esbuild.github.io/
