---
name: shopify-css
description: Use when writing or refactoring CSS in assets/*.css or inside {% stylesheet %} blocks. Covers Theme Store rules (plain CSS only, no minification), {% stylesheet %} global-bundle pitfall, CSS custom properties for theming, scope rules, page-width grid system, and per-template conditional loading.
---

# Shopify CSS

## When to invoke

- Writing any CSS, in `assets/*.css` or inside a `{% stylesheet %}` block of a section / block / snippet.
- Investigating CSS that bleeds across pages.
- Migrating SCSS → CSS for Theme Store compliance.
- Refactoring inline `{% stylesheet %}` content into reusable files.

## Always pair with

- `shopify-base` — universal rules; the `{% stylesheet %}` pitfall is the most critical shared concern
- `shopify-performance` — bundle size, critical CSS, and per-template conditional loading

## Theme Store CSS rules (HARD constraints)

- **Plain CSS only** — no SCSS / SASS / LESS / Stylus source files in the theme. Compiled output is fine.
- **No minified first-party CSS** — reviewers want to read the source. Third-party libs are exempt.
- **No build system artefacts** in `assets/` — no `.scss`, `.scss.map`, `.css.map`.
- **CSS custom properties (`var(--…)`)** are the recommended pattern for theming.

## The `{% stylesheet %}` global-bundle pitfall (READ THIS FIRST)

Shopify bundles all `{% stylesheet %}` content from sections, blocks, and snippets into ONE file (typically named `section.css` by Shopify CDN) loaded on EVERY page. This is the single biggest CSS architecture trap in Shopify themes.

Implications:

- Every selector inside `{% stylesheet %}` applies on every page where the section/block CSS bundle loads.
- An unscoped selector like `.modal__close-button` in a section's `{% stylesheet %}` block will style ANY `.modal__close-button` element across the storefront.
- Cleaning up section-specific CSS by moving it inline does NOT scope it — it just makes the scope problem invisible.

### Rule: every selector inside `{% stylesheet %}` must be scoped

Good:
```css
.featured-collection .heading { font-size: 32px; }
.featured-collection .grid__item { padding: 16px; }
password-modal details[open] .modal__toggle { position: absolute; }
```

Bad (bleeds globally):
```css
.heading { font-size: 32px; }
.modal__close-button { position: absolute; }
details[open] .modal__toggle { position: absolute; }
*, html, body { box-sizing: border-box; }
```

If you write a rule that CANNOT be scoped (genuine global utility, base typography, reset), it does not belong in a `{% stylesheet %}` block. Put it in `assets/base.css` or `assets/template-X.css`.

## Where each kind of CSS belongs

| CSS scope | File |
|---|---|
| Variables, typography, reset, focus, animations, utilities, page-width grid | `assets/base.css` — loaded globally |
| Component used everywhere (buttons, forms, cards, modals, grid) | `assets/base.css` (under a COMPONENTS section) |
| Component used by 1–2 sections / snippets | inline `{% stylesheet %}` block in that section / snippet, SCOPED to its wrapper class |
| Template-wide rules (e.g. password page reset, product layout) | `assets/template-<name>.css`, loaded conditionally from `stylesheets.liquid` or directly from the layout |
| Third-party widget overrides (Judge.me, Klaviyo) | `assets/base.css` or a conditional `assets/component-X.css` loaded only on templates where the widget renders |

The "if used everywhere → base.css; if used in one spot → inline & scoped" rule keeps the global bundle small AND avoids selector leakage.

## CSS custom properties pattern

Variables go in `:root` at the top of `base.css`:

```css
:root {
  --color-foreground: 0, 0, 0;       /* RGB triplet for use in rgba() */
  --color-background: 255, 255, 255;
  --page-width: 1400px;
  --page-padding: 5rem;
  --page-padding-mobile: 1.5rem;
  --font-body-family: 'Inter', sans-serif;
  --font-body-scale: 1;
  --font-heading-scale: 1;
}
```

Consume via `var()`:

```css
.heading { color: rgb(var(--color-foreground)); }
.button { background: rgba(var(--color-button), var(--alpha-button-background, 1)); }
```

Use RGB triplets (not hex) for colors that need alpha variants — RGB lets you use `rgba(var(--color), 0.5)`.

## Section padding via inline CSS variables

Standard pattern for merchant-controlled padding:

```liquid
<section
  class="featured-collection"
  style="
    --section-padding-top: {{ section.settings.padding_top }}px;
    --section-padding-bottom: {{ section.settings.padding_bottom }}px;
  "
>
```

```css
.featured-collection {
  padding-top: var(--section-padding-top, 40px);
  padding-bottom: var(--section-padding-bottom, 40px);
}
```

`{% style %}` is also valid for emitting Liquid-templated CSS that needs the section id:

```liquid
{% style %}
  .section-{{ section.id }}-padding {
    padding-top: {{ section.settings.padding_top | times: 0.75 | round }}px;
  }
{% endstyle %}
```

## Page-width / container pattern

Standard responsive container:

```css
.page-width {
  width: 100%;
  max-width: var(--page-width);
  margin: 0 auto;
  padding: 0 var(--page-padding-mobile);
}
@media screen and (min-width: 750px) {
  .page-width { padding: 0 var(--page-padding); }
}
```

Apply `.page-width` to the outer wrapper of every section's content.

## Forced colors / reduced motion / focus

Theme Store requires:

```css
@media (prefers-reduced-motion: reduce) {
  *:not(.force-motion) { animation: none !important; transition: none !important; }
}

@media (forced-colors: active) {
  .button { border: 1px solid; }
}

:focus-visible {
  outline: 0.2rem solid rgba(var(--color-foreground), 0.5);
  outline-offset: 0.3rem;
}
```

## Avoid `calc()` with two percentages

`calc(100% * 33.3% / 100%)` is invalid (percent × percent is not a valid type). Browsers may silently drop the property, leaving `height: auto`. Use unitless ratios:

Use: `calc(100% * 0.333)` or `aspect-ratio: 3 / 1`
Avoid: `calc(100% * 33.3%)`

## References

- https://shopify.dev/docs/storefronts/themes/store/requirements#code-and-architecture
- https://shopify.dev/docs/storefronts/themes/architecture/layouts
- https://shopify.dev/docs/api/liquid/tags/stylesheet
