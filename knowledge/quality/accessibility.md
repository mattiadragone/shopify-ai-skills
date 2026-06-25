---
title: Accessibility
summary: WCAG 2.1 AA — thresholds, page-level HTML, landmarks, focus management, color contrast, forms, images, touch targets, component ARIA patterns, testing tools.
---

# Accessibility

Rules for WCAG 2.1 AA, enforced by the Theme Store.

## Theme Store a11y thresholds

| Check | Threshold |
|---|---|
| Lighthouse accessibility score | ≥ 90 on home, product, collection (mobile + desktop) |
| Body text contrast | ≥ 4.5:1 |
| Large text (18pt+ or 14pt bold+) contrast | ≥ 3:1 |
| UI component contrast (borders, focus indicators) | ≥ 3:1 |

## Page-level HTML requirements

- Set `lang` on `<html>`: `<html lang="{{ request.locale.iso_code }}">`.
- Do not disable viewport zooming. Never use `maximum-scale=1` or `user-scalable=no`:
  ```html
  <meta name="viewport" content="width=device-width, initial-scale=1">   <!-- CORRECT -->
  ```
- Use only `tabindex="0"` or `tabindex="-1"`. Never positive `tabindex`.
- Do not use `autofocus` — it disrupts screen reader flow on page load.

## Universal rules

- Every page has a unique `<title>` and exactly one `<h1>`.
- Heading hierarchy never skips levels (`h1` → `h2` → `h3`).
- All non-decorative images have `alt`; decorative images use `alt=""`.
- All interactive elements are keyboard reachable in tab order.
- Focus indicators are visible (`:focus-visible` outline, ≥ 3:1 contrast).
- ARIA only when native HTML can't express the relationship. Prefer `<button>` over `<div role="button">`.
- Skip link to main content at the top of the page.

## Navigation ARIA

- `aria-current="page"` on the active primary-nav link:
  ```liquid
  <a href="{{ link.url }}" {% if link.active %}aria-current="page"{% endif %}>{{ link.title }}</a>
  ```
- **Do not use `role="menu"` / `role="menuitem"`** for site navigation — those imply application-menu
  keyboard behavior. Use `<nav>` with a list of `<a>` elements.

## Landmarks

Every page needs: `<header role="banner">`, `<nav>`, `<main role="main" id="MainContent">` (one only),
`<footer role="contentinfo">`. Sections inside `<main>` use `<section>` / `<article>` / `<aside>` with
`aria-labelledby` pointing to a heading.

## Skip link & visually-hidden helper

```liquid
<a class="skip-to-content-link button visually-hidden" href="#MainContent">
  {{ 'accessibility.skip_to_text' | t }}
</a>
```

```css
.skip-to-content-link:focus { position: absolute; clip: auto; width: auto; height: auto; }
.visually-hidden {
  position: absolute !important; width: 1px; height: 1px; margin: -1px; padding: 0;
  overflow: hidden; clip: rect(0 0 0 0); word-wrap: normal !important;
}
```

## Focus management patterns

### Modal / drawer

```js
class Modal extends HTMLElement {
  open() {
    this.previouslyFocused = document.activeElement;
    this.removeAttribute('hidden');
    this.querySelector('[data-focus-on-open]')?.focus();
    document.addEventListener('keydown', this.onKeydown);
    this.trapFocus();
  }
  close() {
    this.setAttribute('hidden', '');
    document.removeEventListener('keydown', this.onKeydown);
    this.previouslyFocused?.focus();
  }
  onKeydown = (e) => { if (e.key === 'Escape') this.close(); };
  trapFocus() {
    const focusable = this.querySelectorAll('a, button, input, [tabindex]:not([tabindex="-1"])');
    if (!focusable.length) return;
    const first = focusable[0], last = focusable[focusable.length - 1];
    this.addEventListener('keydown', (e) => {
      if (e.key !== 'Tab') return;
      if (e.shiftKey && document.activeElement === first) { last.focus(); e.preventDefault(); }
      if (!e.shiftKey && document.activeElement === last) { first.focus(); e.preventDefault(); }
    });
  }
}
```

### Toggle button state

```html
<button type="button" aria-expanded="false" aria-controls="cart-drawer">Cart</button>
```

JS toggles `aria-expanded` and shows / hides the controlled region.

## Color contrast

Use the `color-scheme` setting type; ensure each preset has matching foreground / background pairs that
pass 4.5:1. For text on images, add an overlay or text shadow. Tool:
https://webaim.org/resources/contrastchecker/

## Forms

- Every input has a visible `<label>` or `aria-label`.
- Add `autocomplete` where browser auto-fill applies (`email`, `given-name`, `postal-code`, `tel`…).
- Required fields use the `required` attribute (not only `aria-required`).
- Error messages use `aria-describedby` linking error to input.
- Group related inputs in `<fieldset>` with `<legend>`.

```liquid
<div class="field">
  <input id="Email" type="email" name="contact[email]" autocomplete="email" required
    {% if form.errors %}aria-invalid="true" aria-describedby="email-error"{% endif %}>
  <label for="Email">{{ 'general.contact.email' | t }}</label>
  {% if form.errors %}<span id="email-error" role="status">{{ 'general.contact.error' | t }}</span>{% endif %}
</div>
```

## Images

- Decorative: `alt=""`. Functional (logo, product thumbnail in a link): `alt="Product name"`, NOT
  `alt="image of …"`. Complex (chart): short `alt` + long description via `aria-describedby`.

## Mobile & touch

- Touch targets on primary controls ≥ **44 × 44 px** (menu links, cart button, hamburger, close buttons,
  variant selectors, submit buttons).
- Support pinch-to-zoom. Provide single-tap alternatives for multi-finger gestures. Never lock orientation.

## Tables

Use semantic table markup for data tables (`<caption>`, `<th scope="col">`, `<th scope="row">`). Never use
`<table>` for layout.

## Video and audio

- Provide closed captions for video; mute auto-playing video (`muted`); allow pausing via Space.
- Provide transcripts for audio; allow pausing auto-playing audio; use native controls.

```html
<video autoplay muted loop playsinline>
  <source src="{{ 'video.mp4' | asset_url }}" type="video/mp4">
  <track kind="captions" src="{{ 'captions-en.vtt' | asset_url }}" srclang="en" label="English">
</video>
```

## SVG icons

Always `aria-hidden="true"` on the `<svg>`. The accessible name comes from the wrapping `<button>` / `<a>`:

```html
<button type="button" aria-label="Search">{% render 'icon-search' %}</button>
```

## Component ARIA patterns

- **Carousels**: `<section aria-roledescription="carousel">` + `aria-label`; dots are `<button>` with
  `aria-current="true"` on active; prev/next have `aria-label`; autoplay pausable; slides
  `aria-roledescription="slide"` + `aria-label="N of M"`.
- **Disclosure / accordion**: trigger is a `<button>` with `aria-expanded` + `aria-controls`; panel has
  matching `id` + `hidden` when collapsed. Native `<details>` / `<summary>` is fine.
- **Tabs**: `role="tablist"`; `role="tab"` + `aria-selected` + `aria-controls` + roving `tabindex`;
  `role="tabpanel"` + `aria-labelledby`; arrow keys move; Home/End jump.

APG references: https://www.w3.org/WAI/ARIA/apg/patterns/ (accordion, breadcrumb, carousel, combobox,
disclosure, menubar, dialog-modal, tabs).

## Reduced motion & forced colors

```css
@media (prefers-reduced-motion: reduce) {
  *:not(.force-motion) { animation: none !important; transition: none !important; }
}
@media (forced-colors: active) {
  .button { border: 1px solid; }
  .icon { color: CanvasText; fill: CanvasText !important; }
}
```

## Translation keys for a11y strings

All visible-to-screen-reader strings are translation keys (`general.accessibility.*`):

```json
{ "general": { "accessibility": {
  "skip_to_text": "Skip to content", "close": "Close",
  "previous_slide": "Previous slide", "next_slide": "Next slide", "loading": "Loading" } } }
```

## Testing & validation tools

- **Accessibility Insights for Web** — guided WCAG assessment, FastPass.
- **WAVE** — visual accessibility feedback on the page.
- **W3C HTML Validator** — catch missing `alt`, invalid ARIA, structural errors.
- **Lighthouse** — automated a11y score, target ≥ 90.
- **Shopify Lighthouse CI GitHub Action** — automate a11y checks on every PR.

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/accessibility
- https://shopify.dev/docs/storefronts/themes/store/requirements
- https://www.w3.org/WAI/WCAG21/quickref/
- https://www.w3.org/WAI/ARIA/apg/
