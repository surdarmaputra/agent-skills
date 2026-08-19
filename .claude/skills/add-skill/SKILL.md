---
name: add-skill
description: "Add a new skill to this agent-skills repo. Use when the user wants to contribute a skill, port an existing skill, or create a new one — even if they say 'create skill', 'add skill', 'new skill', or 'contribute'."
---

## Comm style
Terse. Fragments OK. No articles, no filler, no hedging.
Abbreviate: fn/impl/req/res/auth/DB/UI/prop/comp.
Arrows for flow: A → B. One word when enough.
Code blocks: unchanged, always.

## Boot sequence

1. Read `AGENTS.md` → conventions, structure, standards
2. Read `README.md` → what this repo is, existing skill list
3. Scan `skills/` → existing skill names, avoid duplicates
4. Proceed

---

## Workflow

### Step 1: Capture intent

Extract from conversation:
- Skill name (kebab-case)
- What it does (one sentence)
- Trigger phrases (when should the agent invoke it?)
- Output format (if specific)

Ask only what's missing. One question at a time.

### Step 2: Create skill structure

```
skills/<skill-name>/
├── SKILL.md          ← required
├── references/       ← optional, load on demand
└── assets/           ← optional, templates/snippets
```

### Step 3: Write SKILL.md

Frontmatter requirements:
- `name`: kebab-case, matches directory name
- `description`: single-line quoted string; triggers + action; no multiline

Body must include:
- `## Comm style` block (see template below)
- Clear workflow or instructions
- Output format if non-obvious

Comm style template (include verbatim):
```md
## Comm style
Terse. Fragments OK. No articles, no filler, no hedging.
Abbreviate: fn/impl/req/res/auth/DB/UI/prop/comp.
Arrows for flow: A → B. One word when enough.
Code blocks: unchanged, always.
```

### Step 4: Verify

Run `/verify-project` on the new skill content:
- No secrets or PII
- No org-specific terms
- Generic enough for anyone to use
- Description triggers reliably

### Step 5: Confirm placement

Confirm with user before writing files. Show the proposed SKILL.md content first.

---

## Naming conventions

- All lowercase, hyphens only: `code-review-enhanced`, `grill-me`
- Dir name = `name` in frontmatter
- No version suffixes unless unavoidable

## Quality checklist

- [ ] `name` is kebab-case
- [ ] `description` is single-line, triggers reliably
- [ ] Has `## Comm style` section
- [ ] No hardcoded org/company references
- [ ] No secrets or PII
- [ ] Under 500 lines
- [ ] references/ used for supplementary content, not core logic

## Output

After creating the files, summarize:
```
Created: skills/<name>/SKILL.md
Next: commit and push, or run /verify-project to check
```
