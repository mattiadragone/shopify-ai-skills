---
name: shopify-accessibility
description: Use when building or auditing accessible UI — modals, drawers, dropdowns, carousels, forms, color contrast, focus management, keyboard navigation, ARIA, screen reader announcements. Covers WCAG 2.1 AA targets enforced by the Theme Store, focus order, landmarks, headings, image alt, and the common Shopify component patterns.
---

# Shopify Accessibility

## When to invoke

- Building any interactive UI (modal, drawer, dropdown, tabs, accordion, carousel, etc.).
- Auditing for Theme Store compliance (Lighthouse a11y ≥ 90 on product, collection, home).
- Adding keyboard shortcuts or focus management.
- Reviewing color tokens and contrast ratios.

## Theme Store a11y thresholds

| Check | Threshold |
|---|---|
| Lighthouse accessibility score | ≥ 90 on home, product, collection (mobile + desktop) |
| Body text contrast | ≥ 4.5:1 |
| Large text (18pt+ or 14pt bold+) contrast | ≥ 3:1 |
| UI component contrast (borders, focus indicators) | ≥ 3:1 |

## Page-level HTML requirements

- Set `lang` attribute on the `<html>` element for correct screen reader pronunciation:
  ```liquid
  <html lang="{{ request.locale.iso_code }}">
  ```
- Do not disable viewport zooming. Never use `maximum-scale=1` or `user-scalable=no`:
  ```html
  <!-- CORRECT -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- WRONG — blocks zoom for low-vision users -->
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  ```
- Use only `tabindex="0"` or `tabindex="-1"`. Never use positive `tabindex` values — they break natural DOM focus order.
- Do not use `autofocus` — it disrupts screen reader flow on page load.

## Universal rules

- Every page has a unique `<title>`.
- Every page has exactly one `<h1>`.
- Heading hierarchy never skips levels (`h1` → `h2` → `h3`, no `h1` → `h3`).
- All non-decorative images have `alt` text. Decorative images use `alt=""`.
- All interactive elements (buttons, links, inputs) are keyboard reachable in tab order.
- Focus indicators are visible (`:focus-visible` outline, ≥ 3:1 contrast).
- ARIA only when native HTML can't express the relationship. Prefer `<button>` over `<div role="button">`.
- Skip link to main content at the top of the page.

## Navigation ARIA

- Use `aria-current="page"` on the active link in primary navigation:
  ```liquid
  <a href="{{ link.url }}" {% if link.active %}aria-current="page"{% endif %}>
    {{ link.title }}
  </a>
  ```
- **Do not use `role="menu"` or `role="menuitem"`** for navigation menus. These roles imply application-menu keyboard behavior and are wrong for site navigation. Use `<nav>` with a list of `<a>` elements.

## Landmarks

Every page must have:

- `<header role="banner">` (the site header)
- `<nav>` (the primary navigation)
- `<main role="main" id="MainContent">` (the page content; only one per page)
- `<footer role="contentinfo">` (the site footer)

Sections inside `<main>` use `<section>`, `<article>`, or `<aside>` with `aria-labelledby` pointing to a heading.

## Skip link

```liquid
<a class="skip-to-content-link button visually-hidden" href="#MainContent">
  {{ 'accessibility.skip_to_text' | t }}
</a>
```

CSS:
```css
.skip-to-content-link:focus { position: absolute; clip: auto; width: auto; height: auto; }
```

## Visually-hidden helper

For screen-reader-only text:

```css
.visually-hidden {
  position: absolute !important;
  width: 1px; height: 1px;
  margin: -1px; padding: 0;
  overflow: hidden;
  clip: rect(0 0 0 0);
  word-wrap: normal !important;
}
```

Use for labels that visual users get from context (icon button labels, hidden form labels).

## Focus management patterns

### Modal / drawer open

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
  onKeydown = (e) => {
    if (e.key === 'Escape') this.close();
  };
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
<button type="button" aria-expanded="false" aria-controls="cart-drawer">
  Cart
</button>
```

JS toggles `aria-expanded` and shows / hides the controlled region.

## Color contrast

Use the `color-scheme` setting type and ensure each preset has matching foreground / background pairs that pass 4.5:1.

Tool: https://webaim.org/resources/contrastchecker/

For text on images, add an overlay or text shadow to guarantee contrast in worst-case scenarios.

## Forms

- Every input has a visible `<label>` or `aria-label`.
- Add `autocomplete` attribute to all inputs where browser auto-fill applies (`email`, `given-name`, `family-name`, `postal-code`, `tel`, `new-password`, `current-password`, etc.).
- Required fields use `required` attribute (NOT only `aria-required`).
- Error messages use `aria-describedby` linking the error to the input.
- Group related inputs in `<fieldset>` with `<legend>`.

```liquid
<div class="field">
  <input
    id="Email"
    type="email"
    name="contact[email]"
    autocomplete="email"
    required
    {% if form.errors %}aria-invalid="true" aria-describedby="email-error"{% endif %}
  >
  <label for="Email">{{ 'general.contact.email' | t }}</label>
  {% if form.errors %}
    <span id="email-error" role="status">{{ 'general.contact.error' | t }}</span>
  {% endif %}
</div>
```

## Images

- Decorative (icon, background): `alt=""`.
- Functional (logo, product thumbnail in a link): `alt="Product name"`, NOT `alt="image of …"`.
- Complex (chart, infographic): short `alt` + long description via `aria-describedby`.

In Liquid:

```liquid
{{ product.featured_image | image_tag:
   widths: '375,750,1100',
   sizes: '(min-width: 750px) 50vw, 100vw',
   alt: product.title | escape
}}
```

## Mobile & touch

- Touch targets on primary controls must be at least **44 × 44 px**. Apply to main menu links, cart button, hamburger toggle, close buttons, variant selectors, and submit buttons:
  ```css
  .touch-target {
    min-width: 44px;
    min-height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  ```
- Support pinch-to-zoom — do not suppress it via viewport meta (see page-level requirements above).
- Provide single-tap alternatives for any multi-finger gesture.
- Never lock orientation — support both portrait and landscape.

## Tables

Use semantic table markup for data tables (size charts, comparison tables, order history):

```html
<table>
  <caption>Product size chart</caption>
  <thead>
    <tr>
      <th scope="col">Size</th>
      <th scope="col">Chest (cm)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">S</th>
      <td>88</td>
    </tr>
  </tbody>
</table>
```

- `<caption>` identifies the table for screen readers.
- `<th scope="col">` for column headers, `<th scope="row">` for row headers.
- Never use `<table>` for layout.

## Video and audio

### Video

- Provide closed captions for all video content.
- Mute any auto-playing video by default (`muted` attribute).
- Allow pausing via the Space key.
- Provide descriptive audio for video where visual content conveys meaning.

```html
<video autoplay muted loop playsinline>
  <source src="{{ 'video.mp4' | asset_url }}" type="video/mp4">
  <track kind="captions" src="{{ 'captions-en.vtt' | asset_url }}" srclang="en" label="English">
</video>
```

### Audio

- Provide transcripts for all audio content.
- Allow pausing of auto-playing audio.
- Use native `<audio>` controls.

## SVG icons

Always `aria-hidden="true"` on the `<svg>`. The accessible name comes from the wrapping `<button>` / `<a>`:

```html
<button type="button" aria-label="Search">
  {% render 'icon-search' %}
</button>
```

## Carousels / sliders

- Use a `<section>` with `aria-roledescription="carousel"` and an `aria-label`.
- Pagination dots are `<button>` elements with `aria-current="true"` on the active dot.
- Previous / next buttons have `aria-label="Previous slide"` / `"Next slide"`.
- Autoplay can be paused on hover, focus, and via a visible pause button.
- Slides have `aria-roledescription="slide"` and `aria-label="N of M"`.

Reference: https://www.w3.org/WAI/ARIA/apg/patterns/carousel/

## Disclosure / accordion

- The trigger is a `<button>` with `aria-expanded` and `aria-controls`.
- The panel has `id` matching `aria-controls` and `hidden` attribute when collapsed.
- Optional: `<details>` / `<summary>` native disclosure — Shopify themes use this heavily; style the disclosure marker with `summary::marker` or hide via `list-style-type: none`.

## Tabs

- `role="tablist"` on the tab container.
- `role="tab"`, `aria-selected`, `aria-controls`, `tabindex="0"` on the active tab, `tabindex="-1"` on inactive.
- `role="tabpanel"`, `aria-labelledby` on each panel.
- Arrow keys move between tabs; Home / End jump to first / last.

Reference: https://www.w3.org/WAI/ARIA/apg/patterns/tabs/

## Reduced motion

```css
@media (prefers-reduced-motion: reduce) {
  *:not(.force-motion) { animation: none !important; transition: none !important; }
}
```

Required by Theme Store. Apply to scroll animations, hover transforms, autoplay carousels.

## Forced colors (Windows High Contrast)

```css
@media (forced-colors: active) {
  .button { border: 1px solid; }
  .icon { color: CanvasText; fill: CanvasText !important; }
}
```

## Translation keys for a11y strings

All visible-to-screen-reader strings are translation keys:

```json
{
  "general": {
    "accessibility": {
      "skip_to_text": "Skip to content",
      "close": "Close",
      "previous_slide": "Previous slide",
      "next_slide": "Next slide",
      "loading": "Loading"
    }
  }
}
```

## Component-specific patterns

For detailed ARIA patterns for specific components, see:

- Accordion → https://www.w3.org/WAI/ARIA/apg/patterns/accordion/
- Breadcrumb → https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/
- Carousel → https://www.w3.org/WAI/ARIA/apg/patterns/carousel/
- Combobox → https://www.w3.org/WAI/ARIA/apg/patterns/combobox/
- Disclosure → https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/
- Dropdown menu → https://www.w3.org/WAI/ARIA/apg/patterns/menubar/
- Modal dialog → https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/
- Tabs → https://www.w3.org/WAI/ARIA/apg/patterns/tabs/

## Testing & validation tools

- **[Accessibility Insights for Web](https://accessibilityinsights.io/)** — guided WCAG assessment, FastPass checks.
- **[WAVE](https://wave.webaim.org/)** — visual accessibility feedback directly on the page.
- **[W3C HTML Validator](https://validator.w3.org/)** — catch missing `alt`, invalid ARIA, structural errors.
- **Lighthouse** (built into Chrome DevTools) — automated a11y score, target ≥ 90 for Theme Store.
- **Shopify Lighthouse CI GitHub Action** — automate a11y checks on every PR:
  ```yaml
  # .github/workflows/lighthouse.yml
  name: Lighthouse CI
  on: [pull_request]
  jobs:
    lighthouse:
      runs-on: ubuntu-latest
      steps:
        - uses: Shopify/lighthouse-ci-action@v1
  ```

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/accessibility
- https://shopify.dev/docs/storefronts/themes/store/requirements
- https://www.w3.org/WAI/WCAG21/quickref/
- https://www.w3.org/WAI/ARIA/apg/
