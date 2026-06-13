---
name: shopify-design
description: Use when designing sections, blocks, or full theme layouts. Covers merchant experience principles (antifragile composition, easy setup, purposeful design), customer experience principles (intuitive navigation, mobile-first checkout, cohesive brand), atomic design methodology, empty states, and dark patterns to avoid.
---

# Shopify Theme Design

## When to invoke

- Designing a new section or block layout.
- Evaluating whether a section handles variable content lengths gracefully.
- Auditing navigation, checkout flow, or mobile layouts.
- Setting up empty states and default placeholders.
- Reviewing a design for dark patterns.

## Core principle

Design for the merchant first, then the customer. A well-designed theme is easy for merchants to configure AND builds trust with shoppers.

---

## Merchant experience principles

### Purposeful design

- Design sections and blocks tailored to a specific target audience — define the segment by market, inventory size, and desired shopping experience before starting.
- Build one strong art direction rather than a generic multi-audience theme.
- Use component variations instead of separate components that serve the same purpose.

### Easy setup

- Keep settings to the minimum needed by the majority of merchants. Remove niche / edge-case settings.
- Leverage blocks to reduce sidebar clutter — group related controls into a block rather than exposing them as flat settings.
- Build empty states that use existing store data (product images, collection names) rather than generic placeholders or Lorem Ipsum.

### Antifragile composition

Layouts must hold up without perfect content. Test every component against:

- Short and long text strings.
- Portrait and landscape images with non-ideal ratios.
- Missing images (product without photo).
- Very small and very large product counts.
- Mixed content types in a section that accepts multiple block types.

Apply atomic design methodology — clear element hierarchy from atoms (typography, color tokens) to molecules (cards, badges) to organisms (product grids, hero sections).

Font hierarchy must scale consistently:

```css
/* Bind ALL heading levels to the same heading font setting */
h1, h2, h3, h4, h5, h6 { font-family: var(--font-heading-family); }
```

Color system must be applied consistently across the theme to ensure accessibility holds in every color scheme — don't hard-code colors outside the scheme tokens.

Prevent critical CTAs from being covered by app overlays (cookie banners, live chat bubbles). Test with common apps installed.

### Flexible customization

- All flexibility must be predictable — no "magic" settings that behave differently depending on hidden conditions.
- Align settings with SEO, accessibility, responsiveness, and i18n best practices.
- Don't replace native Shopify platform functionality with custom theme settings.
- Don't provide workarounds that go beyond content display and layout.

### Extensible architecture

- Support metafields, theme blocks, and app blocks in sections that have clear use cases.
- Enable app blocks in sections where merchants commonly add conversion tools (product info, cart).

---

## Customer experience principles

### Intuitive navigation

- Design navigation for the target segment — e.g., inspirational category flows for fashion, quick SKU search for B2B.
- Make the primary navigation prominent and discoverable; menu interactions must be intuitive.
- Provide clear entry points: featured collections, highlighted products, promotional banners.
- Product pages must prominently show: title, price, and buy button without scrolling on mobile.
- Use standard, established iconography to minimize cognitive load (cart = bag/cart icon, search = magnifier).
- Test with real users completing a purchase scenario end-to-end.

### Avoid dark patterns

- Never hide costs, auto-select paid add-ons, or use misleading urgency timers.
- Prioritize customer interests over conversion tricks.
- Design patterns must build trust, not exploit it.

### Cohesive brand expression

- Maintain consistent scale, spacing, weight, and layout patterns across all page types.
- The merchant's brand voice and visual identity should be readable throughout navigation, product pages, and checkout.

### Efficient checkout flow

- Limit the number of steps to complete a purchase.
- Enable accelerated checkout (Shop Pay, Apple Pay, Google Pay) by default.
- Design interaction feedback to feel immediate and performant — use optimistic UI where appropriate.
- Optimize all layouts for mobile-first — the majority of Shopify traffic is mobile.

### Expressive storytelling

- Include sections for lifestyle imagery, video, and varied text layouts so merchants can communicate identity and value proposition.
- Don't restrict the theme to product-only content — editorial and brand sections are required for a complete theme.

---

## Designer–developer collaboration

- Establish a feedback loop between designers and developers before starting implementation.
- Don't sacrifice performance for design aesthetics — consult `shopify-performance` before adding heavy visual effects.
- Test designs with theme-check and Lighthouse before submission, not after.

---

## References

- https://shopify.dev/docs/storefronts/themes/best-practices/design
- https://shopify.dev/docs/storefronts/themes/best-practices/templates-sections-blocks
- https://shopify.dev/docs/storefronts/themes/store/requirements
