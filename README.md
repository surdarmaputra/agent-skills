# agent-skills

A library of reusable agent skills — structured instruction sets that extend LLM coding assistants with repeatable, high-quality workflows. Skills are generic by design: no org-specific content, no secrets, usable by anyone.

## Skills

| Skill | What it does |
|---|---|
| [`code-review-enhanced`](skills/code-review-enhanced/) | Evidence-led code review with per-language reference guides, CRITICAL/LOGIC/HARNESS/FE/NITPICK labels, and a 5-dimension quality score |
| [`grill-me`](skills/grill-me/) | Relentless one-question-at-a-time interrogation of a plan or design before building |
| [`prd-to-rfc`](skills/prd-to-rfc/) | Turn a Product Requirements Doc into a structured RFC |
| [`skill-creator-compact`](skills/skill-creator-compact/) | Create, iterate, and quality-check skills with terse workflow + compress/simulate steps |
| [`conventional-commit`](skills/conventional-commit/) | Format commits as conventional commits and keep PR title + description in sync after every push |

---

## Quickstart: Install skills

No need to clone the repo. The installer fetches only what you need directly from GitHub.

```bash
AGENT_SKILLS="bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh)"
```

### 1. List available skills

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --list
```

```
Available skills:
  code-review-enhanced           Review diffs with per-language guides and quality scoring
  grill-me                       Relentless one-question-at-a-time interrogation of a plan
  prd-to-rfc                     Convert PRDs to structured RFCs
  skill-creator-compact          Create and iterate on skills with terse workflow
```

### 2. Install the skills you want

**Global** — available in all your projects:

```bash
# One skill
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) grill-me

# Multiple skills
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) grill-me code-review-enhanced

# Everything
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --all
```

**Project-local** — only available in the current project:

```bash
cd your-project
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --project grill-me
```

Then invoke with a slash command in Claude Code:

```
/grill-me
/code-review-enhanced
```

### 3. Update installed skills

Re-run the same install command — it overwrites in place. Or use `--update` to refresh everything already installed:

```bash
# Update all globally installed skills
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --update

# Update all skills in a project
cd your-project
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --project --update
```

`--update` only touches skills already present in the destination — it won't add new ones.

---

## Install for other coding agents

Run the installer with `--all` first to get a local copy of the skill files, then follow the agent-specific steps below.

```bash
# Download all skills to a temp location
bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) --all
```

The skills land in `~/.claude/skills/`. Use those files for the steps below, replacing `~/agent-skills/skills/` with `~/.claude/skills/`.

Alternatively, clone the repo if you prefer a persistent local copy:

```bash
git clone https://github.com/surdarmaputra/agent-skills.git ~/agent-skills
```

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
2. Open a Claude Code session in the repo root — `scripts/bootstrap.sh` runs automatically and installs [Lefthook](https://github.com/evilmartians/lefthook) + activates the pre-push hook
3. Run `/add-skill` — it scaffolds the file structure and checks for quality
4. Push — Lefthook runs `scripts/verify-project.sh` automatically before every push and blocks if issues are found
5. Submit a PR

If you're not using Claude Code, run setup manually:

```bash
bash scripts/bootstrap.sh
```

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
