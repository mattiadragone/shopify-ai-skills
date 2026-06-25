---
title: Theme Store
summary: Theme Store submission requirements — thresholds, required templates and features, browser matrix, code rules, settings, design uniqueness, Partner Program compliance, submission checklist.
---

# Theme Store

The canonical reference for Shopify Theme Store submission requirements.

## Hard thresholds

| Area | Threshold |
|---|---|
| Lighthouse performance | ≥ 60 on product, collection, home (mobile + desktop) |
| Lighthouse accessibility | ≥ 90 on product, collection, home (mobile + desktop) |
| Color contrast (body text) | ≥ 4.5:1 |
| Color contrast (large text 18pt+) | ≥ 3:1 |

If a change drops Lighthouse performance below 60 on any of those pages, the submission is rejected.
→ details in `knowledge/quality/performance.md` and `knowledge/quality/accessibility.md`.

## Required templates

`index.json`, `product.json`, `collection.json`, `list-collections.json`, `blog.json`, `article.json`,
`page.json`, `cart.json`, `search.json`, `404.json`, `password.json`, `gift_card.liquid` (Liquid), and
customer-area templates (`login`, `register`, `account`, `order`, `addresses`, `activate_account`,
`reset_password` — all `.liquid`). → `knowledge/areas/templates.md`.

## Required features

- **Sections Everywhere (OS 2.0)**: every JSON template allows app/section blocks; header and footer MUST
  be section groups (`sections/header-group.json`, `sections/footer-group.json`), not hardcoded.
- **Accelerated checkout buttons**: cart page shows the Shop Pay / Apple Pay / Google Pay group via
  `{{ form | payment_button }}`.
- **Gift cards**: support purchasing AND redeeming; `templates/gift_card.liquid` shows card image, code,
  expiration, download link.
- **Faceted search filtering**: collection and search pages support `filter`-object filters, keyboard
  navigable.
- **Predictive search**: header search uses the predictive-search endpoint (`/search/suggest.json` or
  `<predictive-search>`).
- **Product recommendations**: product page includes related-products via the `recommendations` object.
- **Rich media**: product galleries support image, video, 3D model, external video.
- **Multi-language and multi-currency**: all visible text uses translation keys; currency/locale selectors
  where markets apply.
- **Newsletter signup**: a form using `{% form 'customer' %}`.
- **Shop Pay features**: accelerated checkout button, Login with Shop, shop avatar in header, Shop Pay
  Installments on product price.

## Browser / device support

- **Desktop**: Safari (latest 2), Chrome (latest 3), Firefox (latest 3), Edge (latest 2).
- **Mobile**: iOS Safari (latest), Chrome Mobile Android (latest), Samsung Internet (latest).
- **Webviews**: Instagram, Facebook, Pinterest in-app browsers.

Avoid features that fail in older Safari (e.g. `flex gap` needs a Safari fallback in `base.css`).

## Code / architecture rules

- Native CSS only — no Sass / SCSS source files.
- No minified first-party CSS / JS (third-party vendor libs exempt).
- Protocol-relative URLs for external CDN references.
- No app-dependent features — theme functions without any installed app.
- No mock data, no fake customer / order info in templates.
- Third-party libraries must include LICENSE files.

→ canonical baseline in `knowledge/universal.md` §6.

## Settings / customization

- Setting labels in clear, merchant-friendly language, grouped logically with header separators.
- At least 4 color schemes, each with matching foreground / background.
- Every font picker supports bold, italic, and bold-italic variants in the chosen family.
- → `knowledge/areas/config.md`.

## Design uniqueness

- Cannot reuse another Theme Store theme's design (cosmetic-only changes are rejected).
- Must demonstrate architectural innovation — new section types, layout systems, interaction patterns.
- Designs must hold up across varying content lengths and as new sections / settings are added.

## Demo store requirement

Each preset needs at least one demo store with authentic content: no Lorem Ipsum, no generic stock
photos, realistic product names/prices/descriptions, realistic blog posts.

## Documentation / support

FAQ in the docs site; functional support contact form; support response within 2 business days; public
changelog of theme updates.

## Deceptive code — Partner Program compliance

Compliance requirements under the Partner Program Agreement and API Terms of Service. Violations can lead
to removal from the Theme Store.

- **No code obfuscation** — there is no legitimate reason to obfuscate a theme; it hides behavior from
  review and harms performance. (Standard minification of third-party libs is separate and fine.)
- **No search engine cloaking** — never present different content to crawlers vs humans, even to boost
  Lighthouse/PageSpeed.
- **No search engine manipulation** — no hidden keyword stuffing, invisible links, fake redirects.
- **General principle** — act with integrity in merchants' interest; review the Partner Program Agreement
  and API Terms of Service regularly.

## Submission checklist (run before submitting)

1. Lighthouse mobile + desktop ≥ 60 (perf) and ≥ 90 (a11y) on home, product, collection.
2. All required templates present.
3. All sections support `@theme` and `@app` blocks.
4. Header and footer are section groups.
5. Gift card purchase + redeem flow works.
6. Accelerated checkout buttons render on cart.
7. Predictive search works.
8. Product recommendations render.
9. Newsletter form submits.
10. No minified / SCSS files in `assets/`.
11. All visible strings are translation keys (no raw `t:` output, no hardcoded English).
12. At least 4 color schemes.
13. Tested in Safari, Chrome, Firefox, Edge, iOS Safari, Android Chrome.
14. Theme works with all apps uninstalled.
15. Demo store uses authentic content, no placeholders.
16. No obfuscated code, no cloaking, no SEO manipulation.

## References

- https://shopify.dev/docs/storefronts/themes/store/requirements
- https://shopify.dev/docs/storefronts/themes/store/review-process/submit-theme
- https://shopify.dev/docs/storefronts/themes/best-practices/performance
- https://shopify.dev/docs/storefronts/themes/best-practices/accessibility
- https://www.shopify.com/partners/terms
- https://www.shopify.com/legal/api-terms
