---
name: verify-project
description: "Scan the project for secrets, PII, sensitive data, and organization-specific terms that would make it non-reusable. Use before committing, publishing, or sharing any skill or file — even if the user doesn't say 'verify'."
---

## Comm style
Terse. Fragments OK. No articles, no filler, no hedging.
Abbreviate: fn/impl/req/res/auth/DB/UI/prop/comp.
Arrows for flow: A → B. One word when enough.
Code blocks: unchanged, always.

## Workflow

Run the script:

```bash
bash scripts/verify-project.sh [path]
```

Default path: repo root. Script exits 0 if clean, 1 if issues found.

After the script runs:
- `[FOUND]` items → fix them; ask the user if ambiguous
- `[INFO]` items → advisory only; surface to user, no fix required unless they ask
- `[CLEAN]` sections → nothing to do

## What the script checks

1. **Secrets & credentials** — API keys, tokens, passwords, private key headers, high-entropy strings
2. **PII** — real email addresses, phone numbers, physical addresses
3. **Org-specific terms** — internal URLs (jira, confluence, notion, linear), "our team/sprint/board" language
4. **Skill reusability** — frontmatter completeness, multiline descriptions, internal URLs in skill bodies

## After fixing

Re-run the script to confirm clean:

```bash
bash scripts/verify-project.sh
```

Then commit. If clean, say so explicitly.
