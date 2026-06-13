# Contributing

Contributions are welcome — new skills, corrections to existing ones, and bug reports are all equally valuable.

## What makes a good skill

- **Focused** — one topic per skill, not a catch-all.
- **Actionable** — concrete rules the AI can follow, not vague advice.
- **Sourced** — links to official Shopify docs or a clear real-world rationale.
- **Tested** — ideally verified against a real Shopify theme before submitting.

## Adding or editing a skill

1. Fork the repo and create a branch.
2. For a **new skill**: create a directory `shopify-<topic>/` with a `SKILL.md` inside.
3. For an **existing skill**: edit the relevant `SKILL.md` directly.
4. Follow the frontmatter format:
   ```markdown
   ---
   name: shopify-topic
   description: Use when ...
   ---
   ```
5. Add a row to the skill table in `README.md` if it's a new skill.
6. Open a pull request with a short description of what changed and why.

## Reporting issues

Open an issue if you find:

- Outdated information (Shopify changes its APIs and conventions frequently).
- Missing coverage for a common Shopify theme pattern.
- Conflicts or contradictions between skills.

## Code of conduct

Be direct and constructive. The goal is accurate, useful rules — not debate.
