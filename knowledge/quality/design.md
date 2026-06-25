---
title: Design
summary: Design principles — merchant experience (antifragile, easy setup, purposeful), customer experience (navigation, checkout, dark patterns), atomic design, empty states.
---

# Design

Design principles for sections, blocks, and full theme layouts.

## Core principle

Design for the merchant first, then the customer. A well-designed theme is easy for merchants to
configure AND builds trust with shoppers.

## Merchant experience principles

### Purposeful design

- Design for a specific target audience — define the segment (market, inventory size, desired shopping
  experience) before starting.
- Build one strong art direction rather than a generic multi-audience theme.
- Use component variations instead of separate components that serve the same purpose.

### Easy setup

- Keep settings to the minimum needed by the majority of merchants. Remove niche / edge-case settings.
- Leverage blocks to reduce sidebar clutter — group related controls into a block rather than flat settings.
- Build empty states that use existing store data (product images, collection names) rather than generic
  placeholders or Lorem Ipsum.

### Antifragile composition

Layouts must hold up without perfect content. Test every component against:

- Short and long text strings.
- Portrait and landscape images with non-ideal ratios.
- Missing images (product without photo).
- Very small and very large product counts.
- Mixed content types in a section that accepts multiple block types.

Apply atomic design — clear hierarchy from atoms (typography, color tokens) to molecules (cards, badges)
to organisms (product grids, hero sections).

Font hierarchy must scale consistently:

```css
/* Bind ALL heading levels to the same heading font setting */
h1, h2, h3, h4, h5, h6 { font-family: var(--font-heading-family); }
```

Apply the color system consistently so accessibility holds in every color scheme — don't hard-code
colors outside the scheme tokens. Prevent critical CTAs from being covered by app overlays (cookie
banners, live chat). Test with common apps installed.

### Flexible customization

- All flexibility must be predictable — no "magic" settings that behave differently under hidden conditions.
- Align settings with SEO, accessibility, responsiveness, and i18n best practices.
- Don't replace native Shopify platform functionality with custom theme settings.
- Don't provide workarounds that go beyond content display and layout.

### Extensible architecture

- Support metafields, theme blocks, and app blocks in sections that have clear use cases.
- Enable app blocks where merchants commonly add conversion tools (product info, cart).

## Customer experience principles

### Intuitive navigation

- Design navigation for the target segment (inspirational flows for fashion, quick SKU search for B2B).
- Make primary navigation prominent and discoverable.
- Provide clear entry points: featured collections, highlighted products, promotional banners.
- Product pages must show title, price, and buy button without scrolling on mobile.
- Use standard iconography (cart = bag, search = magnifier).
- Test with real users completing a purchase end-to-end.

### Avoid dark patterns

- Never hide costs, auto-select paid add-ons, or use misleading urgency timers.
- Prioritize customer interests over conversion tricks. Patterns must build trust, not exploit it.

### Cohesive brand expression

- Maintain consistent scale, spacing, weight, and layout across all page types.
- The merchant's brand voice and visual identity should read throughout navigation, product pages, checkout.

### Efficient checkout flow

- Limit the steps to complete a purchase.
- Enable accelerated checkout (Shop Pay, Apple Pay, Google Pay) by default.
- Make interaction feedback feel immediate; use optimistic UI where appropriate.
- Optimize mobile-first — the majority of Shopify traffic is mobile.

### Expressive storytelling

- Include sections for lifestyle imagery, video, and varied text layouts.
- Don't restrict the theme to product-only content — editorial and brand sections are required for a
  complete theme.

## Designer–developer collaboration

- Establish a feedback loop before implementation.
- Don't sacrifice performance for aesthetics — see `knowledge/quality/performance.md` before adding heavy
  visual effects.
- Test with theme-check and Lighthouse before submission, not after.

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/design
- https://shopify.dev/docs/storefronts/themes/best-practices/templates-sections-blocks
- https://shopify.dev/docs/storefronts/themes/store/requirements
