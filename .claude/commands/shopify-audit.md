---
description: Run a full Shopify theme audit — critical errors, quality checks, and Theme Store submission compliance. Loads all three audit skills in order.
---

Load skills `shopify-audit-critical`, `shopify-audit-quality`, and `shopify-audit-submission` from `.claude/skills/`.

Run the audit in this order:

1. **Critical** (`shopify-audit-critical`) — blocking errors that must be fixed before any merge or submission. Report all findings before moving on.
2. **Quality** (`shopify-audit-quality`) — Lighthouse / performance / accessibility quality checks. Report findings.
3. **Submission** (`shopify-audit-submission`) — Theme Store compliance checklist. Report findings.

After all three layers: print a consolidated summary grouped by severity (blocking / warning / info). List the files and line numbers for each finding.

Do not write any code. Inspection only.
