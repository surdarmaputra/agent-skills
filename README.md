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

### Claude Code (primary target)

Skills in this repo follow the Claude Code skill format. Install globally or per-project.

**Global install** (available in all your projects):

```bash
# Clone repo
git clone https://github.com/surdarmaputra/agent-skills.git ~/agent-skills

# Symlink or copy a skill into Claude Code's global skills dir
mkdir -p ~/.claude/skills
cp -r ~/agent-skills/skills/code-review-enhanced ~/.claude/skills/
cp -r ~/agent-skills/skills/grill-me ~/.claude/skills/
# ... repeat for any skill you want
```

**Per-project install** (available only in one project):

```bash
mkdir -p .claude/skills
cp -r ~/agent-skills/skills/grill-me .claude/skills/
```

Then invoke with a slash command in Claude Code:

```
/grill-me
/code-review-enhanced
```

**Keep skills updated:**

```bash
cd ~/agent-skills && git pull
# Re-copy any skills you want updated
cp -r ~/agent-skills/skills/code-review-enhanced ~/.claude/skills/
```

---

### Cursor

Cursor uses `.cursor/rules/*.mdc` files. Convert a skill to a Cursor rule by copying its body into an `.mdc` file:

```bash
mkdir -p .cursor/rules
# Copy the skill body (without frontmatter) into a rule file
tail -n +5 ~/agent-skills/skills/grill-me/SKILL.md > .cursor/rules/grill-me.mdc
```

Reference the rule in Cursor's settings or prepend it to a prompt manually.

---

### Windsurf

Windsurf reads `.windsurf/rules/*.md` or a root `.windsurfrules` file.

```bash
mkdir -p .windsurf/rules
cp ~/agent-skills/skills/grill-me/SKILL.md .windsurf/rules/grill-me.md
```

Or append to a single rules file:

```bash
cat ~/agent-skills/skills/grill-me/SKILL.md >> .windsurfrules
```

---

### GitHub Copilot (custom instructions)

Copilot reads `.github/copilot-instructions.md`. Paste the skill body there:

```bash
cat ~/agent-skills/skills/grill-me/SKILL.md >> .github/copilot-instructions.md
```

Note: Copilot does not support slash-command invocation — the instructions are always active.

---

### Aider

Aider reads `CONVENTIONS.md` or any file passed via `--read`. Add a skill as a read-only context file:

```bash
# Add to a session
aider --read ~/agent-skills/skills/code-review-enhanced/SKILL.md

# Or add to aider config permanently
echo "read: ~/agent-skills/skills/code-review-enhanced/SKILL.md" >> .aider.conf.yml
```

---

### Cline / RooCode

These read `.clinerules` or `.roo/rules/*.md`. Copy the skill body:

```bash
cat ~/agent-skills/skills/grill-me/SKILL.md >> .clinerules
```

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
