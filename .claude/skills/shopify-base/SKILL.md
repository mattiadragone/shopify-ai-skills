---
name: shopify-base
description: Load for ANY Shopify theme task alongside every other shopify-* skill. Contains universal cross-cutting rules that apply to every file type and are the most common source of bugs and Theme Store rejections — CSS global bundle pitfall, t: prefix in schemas, script deferral, block.shopify_attributes, image lazy loading, and the Theme Store code baseline.
---

# Shopify Base Rules

These rules apply to every file in a Shopify theme. They are the most common source of bugs and Theme Store rejections. Load this skill alongside any other shopify-* skill.

---

## CSS global bundle pitfall

Every `{% stylesheet %}` block in sections, snippets, and blocks is concatenated into ONE `section.css` file loaded on every page. Selectors are NOT scoped automatically.

**Rule: every selector inside a `{% stylesheet %}` block must be scoped to a unique class on the root element of that component.**

```liquid
{# WRONG — leaks globally, affects every h2 on every page #}
{% stylesheet %}
  h2 { color: red; }
  .button { padding: 12px; }
{% endstylesheet %}

{# CORRECT — scoped to this component only #}
{% stylesheet %}
  .section-hero h2 { color: red; }
  .section-hero .button { padding: 12px; }
{% endstylesheet %}
```

---

## t: prefix — schema strings must always be translated

Every `name`, `label`, `info`, `placeholder`, and `content` field in a section or block schema must use the `t:` prefix pointing to a key in `*.default.schema.json`. Hardcoded English strings cause Theme Store rejection.

```json
{ "label": "t:settings.heading" }   ✓
{ "label": "Heading" }              ✗  — Theme Store rejection
```

The key must exist in `locales/en.default.schema.json`:

```json
{ "settings": { "heading": "Heading" } }
```

---

## defer on all scripts

Every `<script src="...">` tag must have `defer`. Synchronous scripts block the HTML parser and tank Lighthouse scores.

```liquid
{# WRONG — parser-blocking #}
{{ 'component.js' | asset_url | script_tag }}

{# CORRECT — deferred #}
<script src="{{ 'component.js' | asset_url }}" defer></script>
```

Use `{% javascript %}` inside sections/blocks for section-scoped JS — it is deferred automatically.

---

## block.shopify_attributes — mandatory on block root

Every theme block must render `{{ block.shopify_attributes }}` on its root element. Without it the block cannot be selected in the theme editor.

```liquid
{# WRONG — block not selectable in editor #}
<div class="block-text">{{ block.settings.text }}</div>

{# CORRECT #}
<div {{ block.shopify_attributes }} class="block-text">{{ block.settings.text }}</div>
```

---

## Images — lazy loading + explicit dimensions

Every image below the fold must have `loading="lazy"`. Every image must have explicit `width` and `height` attributes (not CSS-only) to prevent Cumulative Layout Shift (CLS).

```liquid
{{ image | image_tag:
   widths: '375,750,1100',
   sizes: '(min-width: 750px) 50vw, 100vw',
   loading: 'lazy',
   width: image.width,
   height: image.height,
   alt: image.alt | default: image.src | split: '/' | last | escape
}}
```

Only the LCP candidate (hero, first product image above the fold) uses `loading="eager"`.

---

## Theme Store code baseline

These cause instant rejection if violated:

| Rule | Check |
|---|---|
| No `.scss` / `.sass` files in `assets/` | `find assets/ -name "*.scss"` |
| No minified first-party CSS/JS | `find assets/ -name "*.min.*"` |
| Theme works with zero apps installed | Manual test |
| No obfuscated code | No `eval()`, `atob()`, encoded strings in first-party JS |
| No search engine cloaking | No user-agent sniffing to serve different content |
