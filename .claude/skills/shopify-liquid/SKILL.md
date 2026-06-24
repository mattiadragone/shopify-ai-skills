---
name: shopify-liquid
description: Use when writing or debugging Liquid code in any .liquid file. Covers core tags (if/for/assign/render/capture), filters (string/array/money/image), the {% liquid %} multi-line block, render vs include, and the new {% content_for 'blocks' %} OS 2.0 block API.
---

# Liquid Syntax

## When to invoke

- Writing any Liquid logic in `.liquid` files.
- Debugging a `LiquidError` or unexpected output.
- Choosing between control flow tags (`if` / `unless` / `case`).
- Refactoring nested Liquid into a `{% liquid %}` block.

## Always pair with

- `shopify-base` — universal rules (mandatory for all theme files)

## Output and tags

Two syntaxes:

- `{{ output }}` — print a value, applies filters.
- `{% tag %}` — control flow, assignment, includes. No output unless via `echo` inside a `{% liquid %}` block.

Whitespace-control variants:

- `{%- … -%}` strips surrounding whitespace.
- `{{- … -}}` same for output.

Use the `-` form aggressively in production templates to keep rendered HTML clean.

## Control flow

```liquid
{%- if product.available -%}
  In stock
{%- elsif product.tags contains 'preorder' -%}
  Pre-order
{%- else -%}
  Sold out
{%- endif -%}

{%- unless customer -%}
  <a href="{{ routes.account_login_url }}">Log in</a>
{%- endunless -%}

{%- case product.type -%}
  {%- when 'Shirt', 'Pants' -%}
    Clothing
  {%- when 'Mug' -%}
    Drinkware
  {%- else -%}
    Other
{%- endcase -%}
```

## Loops

```liquid
{%- for variant in product.variants limit: 5 offset: 0 -%}
  {{ variant.title }}
  {%- if forloop.first -%}First!{%- endif -%}
  {%- if forloop.last -%}Last!{%- endif -%}
  {{- forloop.index -}}
{%- endfor -%}
```

`forloop` provides `index`, `index0`, `first`, `last`, `length`, `rindex`. Use `break` and `continue` for early exit.

## Variables

```liquid
{%- assign heading = section.settings.heading | default: 'Welcome' -%}
{%- assign price = variant.price | money -%}

{%- capture button_html -%}
  <button>{{ 'cart.general.add' | t }}</button>
{%- endcapture -%}
{{ button_html }}
```

## The `{% liquid %}` block

Multi-line Liquid logic should live in a single `{% liquid %}` block at the top of the file. Inside, drop the `{% %}` wrappers around each statement.

```liquid
{%- liquid
  assign product = product | default: empty
  assign show_vendor = show_vendor | default: false
  if product.compare_at_price > product.price
    assign on_sale = true
  endif
  if section.settings.heading != blank
    assign heading = section.settings.heading
  else
    assign heading = 'products.product.default_heading' | t
  endif
-%}
```

Use `echo` inside `{% liquid %}` if you must output something:

```liquid
{%- liquid
  assign url = product.url | within: collection
  echo url
-%}
```

## Includes: `render` vs `include`

Always use `render`. `include` is deprecated and shares the parent scope.

```liquid
{% render 'product-card', product: product, show_vendor: true %}
{% render 'icon-cart' %}
```

`with` / `as` pattern for renaming:

```liquid
{% render 'card' with product as item %}
```

`for` pattern for iterating:

```liquid
{% render 'list-item' for collection.products as product %}
```

## Theme blocks (OS 2.0)

```liquid
{% content_for 'blocks' %}                                  {# dynamic blocks #}
{% content_for 'block', type: 'heading', id: 'main-heading' %}  {# static block #}

{% sections 'header-group' %}                               {# render a section group #}
{% section 'main-product' %}                                {# render a single section #}
```

## Forms

```liquid
{% form 'cart' %}
  {% for item in cart.items %}
    <input type="number" name="updates[]" value="{{ item.quantity }}">
  {% endfor %}
  <button type="submit">Update</button>
{% endform %}

{% form 'product', product %}
  <input type="hidden" name="id" value="{{ product.selected_or_first_available_variant.id }}">
  <button type="submit">Add to cart</button>
{% endform %}

{% form 'customer_login' %}
  <input type="email" name="customer[email]">
  <input type="password" name="customer[password]">
  <button type="submit">Log in</button>
{% endform %}
```

## Common filters

**String**: `escape`, `truncate: 150`, `truncatewords: 20`, `handleize`, `replace: 'old','new'`, `upcase`, `downcase`, `capitalize`, `split: ','`, `strip_html`, `strip_newlines`.

**Array**: `compact`, `concat: arr`, `find: 'prop', value`, `where: 'prop', value`, `map: 'prop'`, `sort`, `sort_natural`, `reverse`, `first`, `last`, `size`, `join: ', '`.

**Number / money**: `money`, `money_with_currency`, `money_without_currency`, `money_without_trailing_zeros`, `times`, `divided_by`, `plus`, `minus`, `round`, `ceil`, `floor`, `abs`, `at_least: x`, `at_most: x`.

**Image / asset**: `asset_url`, `image_url: width: 800`, `image_tag: widths: '375,750'`, `inline_asset_content`, `font_url`, `font_face`.

**URL**: `url_for_type`, `link_to`, `within: collection`.

**Date**: `date: '%Y-%m-%d'`, `date: '%B %-d, %Y'`.

**Translation**: `t`, `t: key: value`.

**Default**: `default: 'fallback'`.

## Comments

```liquid
{% comment %}
  Multi-line comment, server-side, never rendered.
{% endcomment %}

{# Inline comment, server-side, never rendered. #}
```

`<!-- HTML comment -->` IS rendered to the client (visible in view-source).

## CRITICAL pitfalls

- **No JS in Liquid**: never use `{% if customer.email == 'test@test.com' %}` to gate features client-side. Liquid runs server-side; the rendered output is cached. Use JS / cookies for per-visitor logic.
- **`include` is deprecated**: use `render` everywhere. `include` leaks scope and breaks caching.
- **Don't put `{% schema %}` content in a snippet** — only sections and blocks have schemas.
- **`{% style %}` vs `{% stylesheet %}`**: `{% style %}` is rendered inline as `<style>` per render (Liquid runs inside). `{% stylesheet %}` is extracted to a section bundle by Shopify. NOT interchangeable.

## References

- https://shopify.dev/docs/api/liquid
- https://shopify.dev/docs/api/liquid/tags
- https://shopify.dev/docs/api/liquid/filters
- https://shopify.dev/docs/api/liquid/objects
