---
name: shopify-version-control
description: Use when setting up or reviewing version control for a Shopify theme project. Covers branch strategy, managing source vs compiled code, git subtree for deploy branches, and the Shopify GitHub integration constraints.
---

# Shopify Theme Version Control

## When to invoke

- Setting up a git repository for a new Shopify theme.
- Deciding how to manage source code vs compiled/uploaded code.
- Configuring Shopify GitHub integration.
- Setting up a CI/CD deploy pipeline for theme pushes.

---

## Branch strategy

### Main branch → production

Connect your `main` (or `master`) branch directly to the Shopify store via the GitHub integration. When main is updated, Shopify pulls and publishes the result.

Use non-main branches temporarily for time-limited campaigns (sale, seasonal) — switch the connected branch to the campaign branch, then switch back when done.

### Deploy branch pattern (for build pipelines)

If you use a build pipeline (compile SCSS, bundle JS, inline SVGs, etc.):

1. Keep `main` as your **source** branch — developers commit source here.
2. Maintain a separate `deploy` (or `dist`) branch as your **compiled** branch — the CI/CD pipeline pushes compiled output here.
3. Connect the `deploy` branch to Shopify, not `main`.

```
main  →  [CI builds]  →  deploy  →  Shopify store
```

---

## Managing source vs compiled code

Shopify themes uploaded via GitHub integration must use the standard theme folder structure. You cannot upload a `src/dist` layout — the root must contain `assets/`, `sections/`, `snippets/`, etc. directly.

Choose one of the four strategies below:

### 1. Separate repositories (easiest migration)

- One repo for source code.
- One repo for compiled/uploadable code.
- Static files are copied between repos.

**Pros:** Easy to start; clear separation.
**Cons:** Extra maintenance burden; static assets duplicated.

### 2. Branch separation — RECOMMENDED

- `main` contains source code.
- A `deploy` branch contains compiled output, managed via `git subtree`.

```bash
# Push compiled output from ./dist to the deploy branch
git subtree push --prefix dist origin deploy
```

**Pros:** Single repo; clean commit history; compatible with Shopify GitHub integration.
**Cons:** Must manage multiple preview branches for staging environments.

### 3. Mixed approach

- Source and compiled files live in the same directory structure.
- Build step reduces compiled file count.

**Pros:** Fewer files overall.
**Cons:** Risk of merchants directly editing compiled files in the Shopify admin code editor, which won't survive a rebuild.

### 4. Source-only versioning (no GitHub integration)

- Only source code is versioned.
- Compiled output is uploaded manually via Shopify CLI (`shopify theme push`).

**Pros:** Simple; well-supported by the Shopify community.
**Cons:** Incompatible with Shopify GitHub integration; manual backfilling required if merchants edit code in admin.

---

## Critical constraint

**Connected branches must match the default Shopify theme folder structure.** You cannot have a `src/` or `dist/` folder at the root of a branch connected to Shopify. The root must contain `assets/`, `config/`, `layout/`, `locales/`, `sections/`, `snippets/`, `templates/`.

---

## Merchant customization risk

After a theme is published, merchants can edit files directly in the Shopify admin code editor. Apps can also modify files via the Asset REST Admin API. If you later rebuild and push from source, merchant changes to compiled code will be overwritten.

**Mitigation:** Use the branch separation strategy so source and compiled code are cleanly separated, and use Shopify GitHub commit history to identify merchant-made changes before rebuilding.

---

## Just-in-time (JIT) alternative

Instead of maintaining a build pipeline, use Shopify's native JIT file transformations:

- Shopify automatically minifies CSS and JS files when uploaded.
- When source files update, Shopify regenerates minified versions automatically.
- No build step needed for minification.

This approach keeps the repo structure compatible with Shopify GitHub integration and eliminates the backfilling problem.

---

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/version-control
- https://shopify.dev/docs/storefronts/themes/best-practices/file-transformation
- https://shopify.dev/docs/storefronts/themes/tools/cli
