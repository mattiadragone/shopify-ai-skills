---
title: JavaScript
summary: JS standards — Custom Elements, the {% javascript %} bundle, theme editor events, defer order, pubsub, fetch/cart API, CSP pitfalls.
---

# JavaScript

Standards for JS in `assets/*.js` and inside `{% javascript %}` blocks.

## Theme Store JS rules

- **No minified first-party JS** in `assets/`. Reviewers want readable source.
- **Third-party vendor bundles** (Swiper, GSAP) ARE allowed minified.
- **No transpilation source maps** in production (`*.map`).
- **No app-dependent features** — the theme must function without any installed app.

## The `{% javascript %}` per-section block

Like `{% stylesheet %}`, `{% javascript %}` content is auto-bundled by Shopify into a `section.js` file
loaded on every page. It runs ONCE per page load, not per section render.

```liquid
{% javascript %}
  class MySection extends HTMLElement {
    connectedCallback() {
      this.button = this.querySelector('button');
      this.button.addEventListener('click', this.onClick.bind(this));
    }
    onClick() { console.log('clicked'); }
  }
  customElements.define('my-section', MySection);
{% endjavascript %}
```

Pitfall: code inside `{% javascript %}` runs once. If multiple instances of the section exist on a page,
each must initialize itself (via Custom Element `connectedCallback`, NOT
`document.querySelector('my-section').init()`).

## Custom Elements pattern (recommended)

```js
class ProductCard extends HTMLElement {
  connectedCallback() {
    this.addToCartButton = this.querySelector('[data-add-to-cart]');
    this.addToCartButton?.addEventListener('click', this.onAdd.bind(this));
  }
  disconnectedCallback() { /* tear down listeners, intervals, observers */ }
  onAdd(event) { event.preventDefault(); /* … */ }
}
customElements.define('product-card', ProductCard);
```

```liquid
<product-card data-product-id="{{ product.id }}">
  <button data-add-to-cart>Add</button>
</product-card>
```

Benefits: each instance initializes itself; teardown on removal is automatic; works seamlessly with
theme editor reloads.

## Shopify theme editor events

In the editor, sections / blocks are added/removed/selected without a full reload. Respond to:

```js
document.addEventListener('shopify:section:load',     (e) => { /* e.detail.sectionId, e.target */ });
document.addEventListener('shopify:section:unload',   (e) => { /* cleanup */ });
document.addEventListener('shopify:section:select',   (e) => { /* focus / scroll */ });
document.addEventListener('shopify:section:deselect', (e) => { /* unfocus */ });
document.addEventListener('shopify:section:reorder',  (e) => { /* re-init position-dependent code */ });
document.addEventListener('shopify:block:select',     (e) => { /* highlight block */ });
document.addEventListener('shopify:block:deselect',   (e) => { /* unhighlight */ });
```

With Custom Elements, most of this is handled automatically by `connectedCallback` /
`disconnectedCallback` when the editor reinserts the section DOM.

## Defer loading order

Scripts loaded with `defer` execute in document order AFTER HTML parsing, BEFORE `DOMContentLoaded`.

```liquid
<script src="{{ 'constants.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'pubsub.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'global.js' | asset_url }}" defer="defer"></script>
<script src="{{ 'swiper-element-bundle.js' | asset_url }}" defer="defer"></script>
```

Race condition: if `section.js` uses `swiperEl.swiper.…`, it depends on `swiper-element-bundle.js`
initializing first. Both are deferred → wrapping section JS in
`document.addEventListener('DOMContentLoaded', …)` guarantees the bundle has registered its Custom
Elements by then. → `knowledge/universal.md` §3.

## PubSub pattern for cross-component communication

```js
// assets/pubsub.js
const subscribers = {};
export function subscribe(eventName, callback) {
  subscribers[eventName] ??= [];
  subscribers[eventName].push(callback);
  return () => { subscribers[eventName] = subscribers[eventName].filter(cb => cb !== callback); };
}
export function publish(eventName, data) { (subscribers[eventName] || []).forEach(cb => cb(data)); }
window.PubSub = { subscribe, publish };
```

Used heavily in Dawn / Horizon for cart drawer ↔ cart icon updates.

## Fetch / cart API patterns

```js
async function addToCart(variantId, quantity) {
  const res = await fetch(`${window.Shopify.routes.root}cart/add.js`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify({ items: [{ id: variantId, quantity }] })
  });
  if (!res.ok) throw new Error(`Cart add failed: ${res.status}`);
  return res.json();
}
```

Always use `window.Shopify.routes.root` to support multi-language stores (prefixes like `/en`, `/fr`).

## Accessibility hooks

JS that opens / closes modals / drawers must: focus the first interactive element on open; trap focus
while open; restore focus to the trigger on close; respond to `Escape`; toggle `aria-expanded` on the
trigger. → detailed patterns in `knowledge/quality/accessibility.md`.

## CRITICAL pitfalls

- **No `eval`, no `new Function(...)`** — Shopify CSP blocks them.
- **No global `var` in section JS** — `var foo = …` at the top of a `{% javascript %}` block leaks onto
  `window`. Use IIFE / Custom Element class scope.
- **No `document.write`** — Shopify storefronts block it.
- **No untrusted innerHTML** — escape user input server-side with `escape`, or use `textContent`.

## References

- https://shopify.dev/docs/storefronts/themes/architecture/sections/section-assets
- https://shopify.dev/docs/storefronts/themes/architecture/sections/section-schema#javascript-tag
- https://shopify.dev/docs/storefronts/themes/best-practices/performance
- https://shopify.dev/docs/api/ajax
- https://developer.mozilla.org/docs/Web/Web_Components
