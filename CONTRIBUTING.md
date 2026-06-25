# Contributing

Contributions are welcome — rule corrections, new knowledge files, and bug reports are all valuable.

The project has two kinds of content. Know which you're changing:

- **`knowledge/`** — the rules. Anatomy, rules, examples, thresholds. One topic per file. Single source of
  truth.
- **`skills/`** — the actions. A small set of operation skills that read from `knowledge/`.

## Changing a rule

Edit the one file in `knowledge/` that owns it. Because skills reference knowledge instead of copying it,
every skill that uses the rule updates automatically. Don't restate a cross-cutting rule in multiple
files — link to its canonical home in `knowledge/universal.md` instead.

A good knowledge file is:

- **Focused** — one area per file, not a catch-all.
- **Actionable** — concrete rules with code examples, not vague advice.
- **Sourced** — links to official Shopify docs or a clear rationale.
- **Deduplicated** — references `universal.md` for cross-cutting rules rather than repeating them.

## Adding a knowledge file

1. Create it under `knowledge/areas/`, `knowledge/languages/`, or `knowledge/quality/`.
2. Add minimal frontmatter:
   ```markdown
   ---
   title: Topic
   summary: One line describing what rules this file holds.
   ---
   ```
3. Add it to the layout in `knowledge/README.md`.
4. Reference it from the routing table of the relevant skill (`skills/*/SKILL.md`).

## Adding an action skill

Add a skill **only if it is a genuinely distinct, useful action** (like build or audit). Design,
optimization, and submission are deliberately *not* skills — they are covered by knowledge plus the
existing actions.

1. Create `skills/shopify-<action>/SKILL.md` with frontmatter:
   ```markdown
   ---
   name: shopify-action
   description: Use when ...
   ---
   ```
2. Keep the skill thin: when to invoke, a routing section that names the `knowledge/` files it reads, a
   procedure, and example prompts.
3. Add it to the skills table in `README.md` and `CLAUDE.md`.

## Reporting issues

Open an issue for:

- Outdated information (Shopify changes APIs and conventions frequently).
- Missing coverage for a common theme pattern.
- Conflicts or contradictions between knowledge files.

## Code of conduct

Be direct and constructive. The goal is accurate, useful rules — not debate.
