---
name: shopify-build-tools
description: Use when setting up build tools for a Shopify theme — SCSS compilation, PostCSS, JavaScript bundling, SVG embedding, critical CSS, or evaluating whether to use a build pipeline vs Shopify's native JIT transformations.
---

# Shopify Theme Build Tools

## When to invoke

- Setting up a build pipeline for a new Shopify theme.
- Deciding between SCSS, PostCSS, or plain CSS.
- Bundling JavaScript or inlining SVGs as snippets.
- Evaluating whether to use Shopify's native transformations instead of a custom build.

---

## Core decision: build pipeline vs JIT

Before setting up a build pipeline, consider whether Shopify's native Just-in-Time (JIT) transformations are sufficient:

| Capability | Build pipeline | Shopify native JIT |
|---|---|---|
| CSS minification | Yes | Yes (automatic) |
| JS minification | Yes | Yes (automatic) |
| SCSS compilation | Yes | No |
| PostCSS / Autoprefixer | Yes | No |
| Tailwind CSS | Yes | No |
| SVG embedding | Yes | Manual (copy snippet) |
| Critical CSS inlining | Yes | No |
| JS bundling | Yes | No |
| Merchant edits source files | No (edits compiled) | Yes |
| Backfilling required | Yes | No |

**Recommendation:** use Shopify's native JIT if you only need minification and your CSS/JS is already written as plain, standard files. Add a build pipeline only when SCSS, Tailwind, or JS bundling are genuinely needed.

---

## Common transformations

### SCSS → CSS

Compile SCSS source files to `assets/*.css`. Keep the compiled output in the theme — do not ship `.scss` files to Shopify.

```bash
# Example with sass CLI
sass src/scss/base.scss assets/base.css --style=expanded --no-source-map
```

The Theme Store requires plain CSS (no SCSS source files in `assets/`), unminified. Do not minify first-party CSS — Shopify handles minification.

### PostCSS

Common PostCSS plugins for Shopify themes:

- **Autoprefixer** — adds vendor prefixes for the browser support matrix.
- **cssnano** — minification (only for vendor/third-party CSS; Shopify auto-minifies first-party).
- **tailwindcss** — utility-first CSS generation (purge config must target `.liquid` files).

```js
// postcss.config.js
module.exports = {
  plugins: [
    require('tailwindcss'),
    require('autoprefixer'),
  ],
};
```

Tailwind purge config for Liquid:

```js
// tailwind.config.js
module.exports = {
  content: [
    './layout/**/*.liquid',
    './sections/**/*.liquid',
    './snippets/**/*.liquid',
    './blocks/**/*.liquid',
    './templates/**/*.liquid',
  ],
};
```

### SVGs as Liquid snippets

Inline SVGs via `{% render %}` instead of `<img src="...">` for full CSS control and accessibility:

```bash
# Convert SVG files to Liquid snippets during build
for f in src/icons/*.svg; do
  name=$(basename "$f" .svg)
  cp "$f" "snippets/icon-${name}.liquid"
done
```

Usage:
```liquid
{% render 'icon-arrow' %}
```

### JavaScript bundling

Use esbuild or Rollup for JS bundling. Output to `assets/` as a single entry file:

```bash
esbuild src/js/theme.js --bundle --outfile=assets/theme.js --format=esm
```

Do NOT minify first-party JS — Shopify auto-minifies. Third-party vendor libs may be pre-minified.

### Critical CSS inlining

Extract above-the-fold CSS and inline it in `<head>` to eliminate render-blocking:

```liquid
{%- capture critical_css -%}
  {%- render 'critical-styles' -%}
{%- endcapture -%}
<style>{{ critical_css }}</style>
```

---

## Merchant customization risk

After upload, merchants can edit theme files directly in the Shopify admin code editor. Apps can also modify files via the Asset REST Admin API. If you later rebuild from source and push, those edits will be overwritten.

**Problem:** The compiled file diverges from source.

**Mitigation strategies:**

1. **Use branch separation** (see `shopify-version-control`) — connect a `deploy` branch to Shopify; source changes go through a build → push pipeline.
2. **Use Shopify GitHub commit history** — commits from the Shopify integration show which files were changed by merchants or apps. Backfill those changes into source before the next build.
3. **Prefer JIT where possible** — merchants edit source files, no backfilling needed.

---

## Shopify native auto-minification

Shopify automatically minifies CSS and JS files in `assets/` when they are uploaded. When a source file is updated, the minified version is regenerated automatically. You do not need to minify first-party assets yourself.

This means:
- Ship readable, unminified CSS and JS from your build step.
- Do NOT commit minified first-party files — it violates Theme Store rules AND creates backfilling complexity.

---

## Build tool recommendations

| Use case | Recommended tool |
|---|---|
| SCSS compilation | Dart Sass (`sass` CLI) |
| PostCSS pipeline | PostCSS CLI |
| JS bundling | esbuild (fastest) or Rollup |
| Task runner | npm scripts (no Gulp/Grunt needed) |
| Tailwind CSS | Tailwind CLI or PostCSS plugin |
| File watching | `nodemon` or `--watch` flags on individual tools |

---

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/file-transformation
- https://shopify.dev/docs/storefronts/themes/best-practices/version-control
- https://shopify.dev/docs/storefronts/themes/store/requirements
- https://esbuild.github.io/
