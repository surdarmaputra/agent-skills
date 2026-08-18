# agent-skills

A library of reusable agent skills — structured instruction sets that extend LLM coding assistants with repeatable, high-quality workflows. Skills are generic by design: no org-specific content, no secrets, usable by anyone.

## Skills

| Skill | What it does |
|---|---|
| [`code-review-enhanced`](skills/code-review-enhanced/) | Evidence-led code review with per-language reference guides, CRITICAL/LOGIC/HARNESS/FE/NITPICK labels, and a 5-dimension quality score |
| [`grill-me`](skills/grill-me/) | Relentless one-question-at-a-time interrogation of a plan or design before building |
| [`prd-to-rfc`](skills/prd-to-rfc/) | Turn a Product Requirements Doc into a structured RFC |
| [`skill-creator-compact`](skills/skill-creator-compact/) | Create, iterate, and quality-check skills with terse workflow + compress/simulate steps |

---

## Quickstart: Install skills

### 1. Clone the repo

```bash
git clone https://github.com/surdarmaputra/agent-skills.git ~/agent-skills
```

### 2. List available skills

```bash
bash ~/agent-skills/scripts/install.sh --list
```

```
Available skills:
  code-review-enhanced           Review diffs with per-language guides and quality scoring
  grill-me                       Relentless one-question-at-a-time interrogation of a plan
  prd-to-rfc                     Convert PRDs to structured RFCs
  skill-creator-compact          Create and iterate on skills with terse workflow
```

### 3. Install the skills you want

**Global** — available in all your projects:

```bash
# One skill
bash ~/agent-skills/scripts/install.sh grill-me

# Multiple skills
bash ~/agent-skills/scripts/install.sh grill-me code-review-enhanced

# Everything
bash ~/agent-skills/scripts/install.sh --all
```

**Project-local** — only available in the current project:

```bash
cd your-project
bash ~/agent-skills/scripts/install.sh --project grill-me
```

Then invoke with a slash command in Claude Code:

```
/grill-me
/code-review-enhanced
```

### 4. Update installed skills

Pull the latest from this repo, then re-run the same install command — it overwrites in place.

```bash
# Pull updates
cd ~/agent-skills && git pull

# Update all skills you already have installed (global)
bash ~/agent-skills/scripts/install.sh --update

# Update all skills in a project
cd your-project
bash ~/agent-skills/scripts/install.sh --project --update

# Or update specific skills
bash ~/agent-skills/scripts/install.sh grill-me code-review-enhanced
```

`--update` only touches skills already present in the destination — it won't add new ones.

---

## Install for other coding agents

First clone the repo as above, then follow the agent-specific steps.

### Cursor

Cursor reads `.cursor/rules/*.mdc`. Strip the YAML frontmatter and save as an `.mdc` file:

```bash
mkdir -p .cursor/rules
# Skip the frontmatter (lines between the --- delimiters)
awk '/^---/{p++; next} p>=2' ~/agent-skills/skills/grill-me/SKILL.md \
  > .cursor/rules/grill-me.mdc
```

To update: re-run the same command — it overwrites the file.

---

### Windsurf

Windsurf reads `.windsurf/rules/*.md` or a root `.windsurfrules` file.

```bash
# Per-rule file (recommended — easier to update individually)
mkdir -p .windsurf/rules
cp ~/agent-skills/skills/grill-me/SKILL.md .windsurf/rules/grill-me.md

# Or append to a single rules file
cat ~/agent-skills/skills/grill-me/SKILL.md >> .windsurfrules
```

To update a per-rule file: `cp` again — it overwrites.

---

### GitHub Copilot (custom instructions)

Copilot reads `.github/copilot-instructions.md`. Skills are always active (no slash commands).

```bash
# Append a skill
cat ~/agent-skills/skills/grill-me/SKILL.md >> .github/copilot-instructions.md
```

To update: open the file and replace the skill block manually, or manage each skill between marker comments:

```bash
# Use markers so you can replace cleanly
echo "<!-- skill:grill-me -->" >> .github/copilot-instructions.md
cat ~/agent-skills/skills/grill-me/SKILL.md >> .github/copilot-instructions.md
echo "<!-- /skill:grill-me -->" >> .github/copilot-instructions.md
```

---

### Aider

Aider accepts extra context files via `--read` or `.aider.conf.yml`.

```bash
# Single session
aider --read ~/agent-skills/skills/grill-me/SKILL.md

# Permanent (added to every session in this project)
echo "read: ~/agent-skills/skills/grill-me/SKILL.md" >> .aider.conf.yml
```

To update: `git pull` in `~/agent-skills` — Aider reads the file fresh each session, so updates are automatic if you use the path directly.

---

### Cline / RooCode

These read `.clinerules` or `.roo/rules/*.md`.

```bash
# Per-rule file (recommended)
mkdir -p .roo/rules
cp ~/agent-skills/skills/grill-me/SKILL.md .roo/rules/grill-me.md

# Or append to .clinerules
cat ~/agent-skills/skills/grill-me/SKILL.md >> .clinerules
```

To update a per-rule file: `cp` again.

---

## Contributing a skill

1. Clone this repo
2. Install [Lefthook](https://github.com/evilmartians/lefthook) and activate the hooks:
   ```bash
   # macOS
   brew install lefthook
   # or: npm i -g @evilmartians/lefthook

   lefthook install
   ```
3. Open a Claude Code session in the repo root
4. Run `/add-skill` — it scaffolds the file structure and checks for quality
5. Push — Lefthook runs `scripts/verify-project.sh` automatically before every push and blocks if issues are found
6. Submit a PR

> **Skip the hook once (not recommended):** `git push --no-verify`

### Skill requirements

- **Generic** — works for any user, any codebase, any org
- **No secrets or PII** — keys, tokens, emails, phone numbers
- **No org-specific content** — no internal URLs, product names, team names
- **Self-contained** — references live in `references/`, not external URLs (unless stable public docs)
- **Under 500 lines**

See [`AGENTS.md`](AGENTS.md) for full conventions.

---

## Repo-local skills (for contributors)

When working inside this repo, Claude Code also loads skills from `.claude/skills/`:

| Skill | What it does |
|---|---|
| `add-skill` | Scaffold and quality-check a new skill for this repo |
| `verify-project` | Scan for secrets, PII, and org-specific terms before publishing |
| `grill-me` | Stress-test a skill design before writing it |
| `skill-creator-compact` | Iterate and refine skills with terse workflow |

These are invokable as slash commands when your Claude Code session is open in this repo.
