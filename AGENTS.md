# agent-skills

## What this repo is

A collection of reusable agent skills — instruction sets that extend coding agents with repeatable workflows. Skills are agent-agnostic by design; the primary format targets Claude Code but the content applies to any LLM-powered coding assistant.

## Repo structure

```
agent-skills/
├── skills/                  # public skill library
│   └── <skill-name>/
│       ├── SKILL.md         # required — skill instructions + frontmatter
│       ├── references/      # optional — supplementary docs loaded on demand
│       └── assets/          # optional — templates, snippets
├── .claude/
│   ├── skills/              # repo-local skills for developing this repo
│   └── settings.json        # Claude Code harness config
├── AGENTS.md                # this file
└── README.md
```

## Conventions

### Skill format

Every skill lives in `skills/<name>/SKILL.md`. Frontmatter fields:

```yaml
---
name: kebab-case-name        # matches directory name exactly
description: "Single-line quoted string. Trigger + action. No multiline."
---
```

Body sections (use only what the skill needs):
- `## Comm style` — required; copy the standard block verbatim
- `## Boot sequence` — what to read/check before starting
- `## Workflow` — step-by-step instructions
- `## Output format` — what the agent should produce
- `## Edge cases` — known exceptions

### Naming

- Directory name = `name` in frontmatter
- Kebab-case, all lowercase
- No version suffixes

### Content standards

Skills in this repo must be:
- **Generic** — no hardcoded org names, internal URLs, or product-specific logic
- **Reusable** — anyone in any codebase should be able to use them
- **Clean** — no secrets, PII, or sensitive data
- **Self-contained** — external references go in `references/`, not inline

### File size

- `SKILL.md`: under 500 lines
- `references/*.md`: no hard limit, but prefer focused docs

## Development workflow

1. Run `/add-skill` to scaffold a new skill
2. Run `/verify-project` before committing to check for secrets/PII/org terms
3. Run `/grill-me` to stress-test a skill design before writing it
4. Run `/skill-creator-compact` to refine or iterate on an existing skill

## Stack

No application stack — this is a documentation/instruction repo. Files are Markdown only.

## Quality bar

Before merging any skill:
- [ ] Frontmatter valid: `name` + `description` present, description single-line
- [ ] `## Comm style` block present
- [ ] No org-specific content (run `/verify-project`)
- [ ] Description triggers reliably without requiring exact phrasing
- [ ] Under 500 lines
