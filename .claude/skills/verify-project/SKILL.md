---
name: verify-project
description: "Scan the project for secrets, PII, sensitive data, and organization-specific terms that would make it non-reusable. Use before committing, publishing, or sharing any skill or file — even if the user doesn't say 'verify'."
---

## Comm style
Terse. Fragments OK. No articles, no filler, no hedging.
Abbreviate: fn/impl/req/res/auth/DB/UI/prop/comp.
Arrows for flow: A → B. One word when enough.
Code blocks: unchanged, always.

## Goal

Ensure the project is clean, reusable, and safe to share publicly. No secrets, no PII, no org-specific lock-in.

## Boot sequence

1. Read `AGENTS.md` / `CLAUDE.md` for project context
2. Identify scope: all files not in `.gitignore`, `node_modules`, `.git`
3. Run all 4 checks below
4. Report findings grouped by category

---

## Check 1: Secrets & credentials

Scan for patterns indicating hardcoded secrets:

```bash
# API keys / tokens
grep -rn --include="*.md" --include="*.txt" --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include="*.env*" \
  -E "(api[_-]?key|api[_-]?secret|access[_-]?token|auth[_-]?token|bearer\s+[A-Za-z0-9]{20,}|secret[_-]?key|private[_-]?key|password\s*[:=]\s*\S|passwd\s*[:=]\s*\S)" \
  --exclude-dir=".git" .

# High-entropy strings (potential tokens)
grep -rn --include="*.md" --include="*.txt" \
  -E "['\"][A-Za-z0-9+/]{40,}['\"]" \
  --exclude-dir=".git" .

# Private keys
grep -rn -l "BEGIN.*PRIVATE KEY\|BEGIN.*CERTIFICATE" --exclude-dir=".git" .
```

Flag any match. False positive → note it, still report.

---

## Check 2: PII (Personally Identifiable Information)

```bash
# Email addresses (real, not example.com / test.com)
grep -rn --include="*.md" --include="*.txt" --include="*.json" \
  -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" \
  --exclude-dir=".git" . | grep -v "@example\.\|@test\.\|@domain\.\|user@\|admin@example"

# Phone numbers
grep -rn --include="*.md" --include="*.txt" \
  -E "(\+?[0-9]{1,3}[-.\s]?)?(\([0-9]{2,4}\)[-.\s]?)?[0-9]{3,4}[-.\s]?[0-9]{3,4}[-.\s]?[0-9]{0,4}" \
  --exclude-dir=".git" . | grep -v "20[0-9][0-9]\|port\|http\|line\s\|L[0-9]"

# Physical addresses (heuristic)
grep -rn --include="*.md" --include="*.txt" \
  -E "[0-9]{1,5}\s+[A-Z][a-z]+\s+(Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr)" \
  --exclude-dir=".git" .
```

---

## Check 3: Organization-specific terms

Look for references that tie content to a specific company/team:

```bash
# Internal URLs / domains
grep -rn --include="*.md" --include="*.txt" --include="*.json" \
  -E "https?://[a-zA-Z0-9.-]*(internal|corp|intra|jira|confluence|slack\.com/archives|notion\.so|linear\.app)" \
  --exclude-dir=".git" .

# Common internal tool patterns
grep -rn --include="*.md" --include="*.txt" \
  -E "(our\s+team|our\s+company|at\s+[A-Z][a-z]+\s+(Inc|Corp|Ltd|LLC)|#[a-z]+-[a-z]+\s+channel|slack channel)" \
  --exclude-dir=".git" . | grep -iv "example\|sample\|placeholder"
```

Also manually review all `*.md` files for:
- Proper nouns referring to specific companies, products, or teams
- References to internal processes ("our sprint", "our Jira board")
- Hardcoded project/product names that aren't generic

---

## Check 4: Skill-specific reusability

For each `SKILL.md` file found:

1. Read the skill
2. Check: does it assume a specific tech stack without reading `AGENTS.md`?
3. Check: does it reference internal tools, repos, or URLs?
4. Check: does it contain example data with real names / emails / companies?
5. Check: is the description generic enough to be useful to anyone?

```bash
find . -name "SKILL.md" -not -path "./.git/*"
```

---

## Output format

```
## Verify Project Report

### Secrets & Credentials
- [CLEAN] No secrets found
- [FOUND] <file>:<line> — <description>

### PII
- [CLEAN] No PII found
- [FOUND] <file>:<line> — <description>

### Org-specific Terms
- [CLEAN] No org-specific terms found
- [FOUND] <file>:<line> — <description>

### Skill Reusability
- [CLEAN] All skills are generic
- [ISSUE] <skill-name>: <description>

---
Overall: CLEAN | NEEDS ATTENTION (<N> issues)
```

If `NEEDS ATTENTION`: list each fix needed. Ask user to confirm fixes before modifying files.

---

## Edge cases

- Placeholder text like `YOUR_API_KEY` → not a secret, note as CLEAN with remark
- `example@example.com` → not PII, mark CLEAN
- Skill references a real tool name (e.g. "GitLab") as a concept → fine, not org-specific
- Company name in a code block as an example → flag for review, let user decide
