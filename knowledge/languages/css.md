---
title: CSS
summary: CSS standards — the {% stylesheet %} global-bundle pitfall (authoritative detail), where each kind of CSS belongs, custom properties, page-width grid, conditional loading, Theme Store rules.
---

# CSS

Standards for CSS in `assets/*.css` and inside `{% stylesheet %}` blocks. This file is the authoritative
detail for the CSS scoping problem summarized in `knowledge/universal.md` §1.

## Theme Store CSS rules (hard constraints)

- **Plain CSS only** — no SCSS / SASS / LESS / Stylus source files in the theme. Compiled output is fine.
- **No minified first-party CSS** — reviewers want to read the source. Third-party libs are exempt.
- **No build system artefacts** in `assets/` — no `.scss`, `.scss.map`, `.css.map`.
- **CSS custom properties (`var(--…)`)** are the recommended pattern for theming.

## The `{% stylesheet %}` global-bundle pitfall (read this first)

Shopify bundles all `{% stylesheet %}` content from sections, blocks, and snippets into ONE file
(typically `section.css`) loaded on EVERY page. This is the single biggest CSS architecture trap.

Implications:

- Every selector inside `{% stylesheet %}` applies on every page where the bundle loads.
- An unscoped selector like `.modal__close-button` in a section's `{% stylesheet %}` block styles ANY
  `.modal__close-button` element across the storefront.
- Moving section CSS inline does NOT scope it — it just makes the scope problem invisible.

### Rule: every selector inside `{% stylesheet %}` must be scoped

```css
/* Good */
.featured-collection .heading { font-size: 32px; }
.featured-collection .grid__item { padding: 16px; }
password-modal details[open] .modal__toggle { position: absolute; }

/* Bad — bleeds globally */
.heading { font-size: 32px; }
.modal__close-button { position: absolute; }
details[open] .modal__toggle { position: absolute; }
*, html, body { box-sizing: border-box; }
```

If a rule CANNOT be scoped (genuine global utility, base typography, reset), it does not belong in a
`{% stylesheet %}` block. Put it in `assets/base.css` or `assets/template-X.css`.

## Where each kind of CSS belongs

| CSS scope | File |
|---|---|
| Variables, typography, reset, focus, animations, utilities, page-width grid | `assets/base.css` — global |
| Component used everywhere (buttons, forms, cards, modals, grid) | `assets/base.css` (COMPONENTS section) |
| Component used by 1–2 sections / snippets | inline `{% stylesheet %}` block, SCOPED to its wrapper class |
| Template-wide rules (password page reset, product layout) | `assets/template-<name>.css`, loaded conditionally |
| Third-party widget overrides (Judge.me, Klaviyo) | `assets/base.css` or a conditional `component-X.css` |

"If used everywhere → base.css; if used in one spot → inline & scoped" keeps the global bundle small AND
avoids selector leakage.

## CSS custom properties pattern

```css
:root {
  --color-foreground: 0, 0, 0;       /* RGB triplet for use in rgba() */
  --color-background: 255, 255, 255;
  --page-width: 1400px;
  --page-padding: 5rem;
  --page-padding-mobile: 1.5rem;
  --font-body-family: 'Inter', sans-serif;
}
.heading { color: rgb(var(--color-foreground)); }
.button { background: rgba(var(--color-button), var(--alpha-button-background, 1)); }
```

Use RGB triplets (not hex) for colors that need alpha variants.

## Section padding via inline CSS variables

```liquid
<section class="featured-collection"
  style="--section-padding-top: {{ section.settings.padding_top }}px;
         --section-padding-bottom: {{ section.settings.padding_bottom }}px;">
```

```css
.featured-collection {
  padding-top: var(--section-padding-top, 40px);
  padding-bottom: var(--section-padding-bottom, 40px);
}
```

`{% style %}` is also valid for Liquid-templated CSS that needs the section id:

```liquid
{% style %}
  .section-{{ section.id }}-padding { padding-top: {{ section.settings.padding_top | times: 0.75 | round }}px; }
{% endstyle %}
```

## Page-width / container pattern

```css
.page-width { width: 100%; max-width: var(--page-width); margin: 0 auto; padding: 0 var(--page-padding-mobile); }
@media screen and (min-width: 750px) { .page-width { padding: 0 var(--page-padding); } }
```

Apply `.page-width` to the outer wrapper of every section's content.

## Forced colors / reduced motion / focus

Theme Store requires:

```css
@media (prefers-reduced-motion: reduce) {
  *:not(.force-motion) { animation: none !important; transition: none !important; }
}
@media (forced-colors: active) { .button { border: 1px solid; } }
:focus-visible { outline: 0.2rem solid rgba(var(--color-foreground), 0.5); outline-offset: 0.3rem; }
```

## Avoid `calc()` with two percentages

`calc(100% * 33.3%)` is invalid (percent × percent is not a valid type); browsers may silently drop the
property, leaving `height: auto`. Use `calc(100% * 0.333)` or `aspect-ratio: 3 / 1`.

## CSS subsetting compatibility

Shopify automatically subsets (removes unused CSS). For this to work, CSS classes must only be used
within the file that defines them. Don't reference a class defined in `base.css` from inside a
`{% stylesheet %}` block — the subsetter may remove it.

## References

- https://shopify.dev/docs/storefronts/themes/store/requirements#code-and-architecture
- https://shopify.dev/docs/storefronts/themes/architecture/layouts
- https://shopify.dev/docs/api/liquid/tags/stylesheet
