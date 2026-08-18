#!/usr/bin/env bash
# verify-project.sh — scan for secrets, PII, and org-specific content
# Usage: ./scripts/verify-project.sh [path]
# Exits 0 if clean, 1 if issues found.

set -euo pipefail

ROOT="${1:-.}"
ISSUES=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

found() { echo -e "  ${RED}[FOUND]${RESET} $*"; ISSUES=$((ISSUES + 1)); }
clean() { echo -e "  ${GREEN}[CLEAN]${RESET} $*"; }
info()  { echo -e "  ${YELLOW}[INFO]${RESET}  $*"; }

# Files to scan (exclude binary, generated, git)
SCAN_OPTS=(
  --include="*.md"
  --include="*.txt"
  --include="*.json"
  --include="*.yaml"
  --include="*.yml"
  --include="*.toml"
  --include="*.sh"
  --include="*.env*"
  --exclude-dir=".git"
  --exclude-dir="node_modules"
  --exclude-dir="dist"
  --exclude-dir="vendor"
)

scan() {
  # $1 = label, $2 = pattern, rest = extra grep opts
  local label="$1"; local pattern="$2"; shift 2
  local results
  results=$(grep -rn "${SCAN_OPTS[@]}" "$@" -E "$pattern" "$ROOT" 2>/dev/null || true)
  if [[ -n "$results" ]]; then
    while IFS= read -r line; do
      found "$label → $line"
    done <<< "$results"
  fi
}

echo ""
echo -e "${BOLD}## Verify Project Report${RESET}"
echo -e "${BOLD}   Target: $ROOT${RESET}"
echo ""

# ── 1. Secrets & credentials ─────────────────────────────────────────────────
echo -e "${BOLD}### 1. Secrets & Credentials${RESET}"

BEFORE=$ISSUES
scan "API key/secret" \
  "(api[_-]?key|api[_-]?secret|access[_-]?token|auth[_-]?token)\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}"

scan "Password literal" \
  "(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{4,}['\"]" \
  --ignore-case

scan "Bearer token" \
  "bearer\s+[A-Za-z0-9\-_\.]{20,}" \
  --ignore-case

scan "Private key header" \
  "-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY"

scan "High-entropy string (possible token)" \
  "['\"][A-Za-z0-9+/]{40,}={0,2}['\"]"

# False-positive note for placeholders
PLACEHOLDER_HITS=$(grep -rn "${SCAN_OPTS[@]}" -iE \
  "(YOUR_API_KEY|<api_key>|REPLACE_ME|\$\{[A-Z_]+\}|example_token|fake_token)" \
  "$ROOT" 2>/dev/null | wc -l || true)
[[ "$PLACEHOLDER_HITS" -gt 0 ]] && info "$PLACEHOLDER_HITS placeholder(s) found (YOUR_API_KEY style) — likely fine, verify manually"

[[ $ISSUES -eq $BEFORE ]] && clean "No secrets detected"
echo ""

# ── 2. PII ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}### 2. PII (Personally Identifiable Information)${RESET}"

BEFORE=$ISSUES

# Real emails — skip obvious safe domains
EMAIL_HITS=$(grep -rn "${SCAN_OPTS[@]}" -E \
  "[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}" \
  "$ROOT" 2>/dev/null \
  | grep -viE "@(example|test|domain|placeholder|your\-domain|yourdomain|acme)\." \
  | grep -viE "user@|admin@example|foo@|bar@|noreply@" \
  || true)
if [[ -n "$EMAIL_HITS" ]]; then
  while IFS= read -r line; do
    found "Email → $line"
  done <<< "$EMAIL_HITS"
fi

# Phone numbers (international + local formats, filter out line refs and years)
scan "Phone number" \
  "(\+?[0-9]{1,3}[\s.\-])?(\([0-9]{2,4}\)[\s.\-]?)[0-9]{3,4}[\s.\-][0-9]{3,4}" \
  | grep -viE "L[0-9]|line [0-9]|20[0-9]{2}|port [0-9]" 2>/dev/null || true
# Simpler re-check since we can't pipe scan()
PHONE_HITS=$(grep -rn "${SCAN_OPTS[@]}" -E \
  "(\+?[0-9]{1,3}[\s.\-])?(\([0-9]{2,4}\)[\s.\-]?)[0-9]{3,4}[\s.\-][0-9]{4}" \
  "$ROOT" 2>/dev/null \
  | grep -viE "L[0-9]|20[0-9]{2}|port|http|line [0-9]" \
  || true)
if [[ -n "$PHONE_HITS" ]]; then
  while IFS= read -r line; do
    found "Phone → $line"
  done <<< "$PHONE_HITS"
fi

# Physical addresses
scan "Physical address" \
  "[0-9]{1,5}\s+[A-Z][a-z]+\s+(Street|St\.?|Avenue|Ave\.?|Road|Rd\.?|Boulevard|Blvd\.?|Lane|Ln\.?|Drive|Dr\.?)\b"

[[ $ISSUES -eq $BEFORE ]] && clean "No PII detected"
echo ""

# ── 3. Org-specific terms ────────────────────────────────────────────────────
echo -e "${BOLD}### 3. Organization-Specific Terms${RESET}"

BEFORE=$ISSUES

scan "Internal URL" \
  "https?://[a-zA-Z0-9.\-]*(internal|corp|intra|\.local|jira\.|confluence\.|slack\.com/archives/|notion\.so/|linear\.app/|shortcut\.com/)" \
  --ignore-case

ORG_HITS=$(grep -rn "${SCAN_OPTS[@]}" -iE \
  "(our\s+(team|company|org|organization|sprint|jira|board)|#[a-z]+-[a-z]+-[a-z]+\s+channel)" \
  "$ROOT" 2>/dev/null \
  | grep -viE 'example|sample|placeholder|your.team|your.company|"\s*our\s+|references to|processes \(' \
  || true)
if [[ -n "$ORG_HITS" ]]; then
  while IFS= read -r line; do
    found "Org term → $line"
  done <<< "$ORG_HITS"
fi

[[ $ISSUES -eq $BEFORE ]] && clean "No org-specific terms detected"
echo ""

# ── 4. Skill reusability ─────────────────────────────────────────────────────
echo -e "${BOLD}### 4. Skill Reusability${RESET}"

BEFORE=$ISSUES
SKILL_FILES=$(find "$ROOT" -name "SKILL.md" -not -path "*/.git/*" 2>/dev/null || true)

if [[ -z "$SKILL_FILES" ]]; then
  info "No SKILL.md files found"
else
  while IFS= read -r skill; do
    # Check for missing comm style block (advisory only — older skills may omit it)
    if ! grep -q "## Comm style" "$skill" 2>/dev/null; then
      info "$(basename "$(dirname "$skill")")/SKILL.md — missing '## Comm style' block (recommended for new skills)"
    fi
    # Check frontmatter has name + description
    if ! grep -qE "^name:" "$skill" 2>/dev/null; then
      found "$skill — missing 'name:' in frontmatter"
    fi
    if ! grep -qE "^description:" "$skill" 2>/dev/null; then
      found "$skill — missing 'description:' in frontmatter"
    fi
    # Check for multiline description (pipe/block scalar)
    if grep -qE "^description:\s*[|>]" "$skill" 2>/dev/null; then
      found "$skill — description uses multiline block scalar (must be single-line quoted)"
    fi
    # Rough check for internal URL in skill body
    if grep -qE "https?://[a-zA-Z0-9.\-]*(internal|corp|intra|\.local)" "$skill" 2>/dev/null; then
      found "$skill — contains internal URL"
    fi
  done <<< "$SKILL_FILES"
fi

[[ $ISSUES -eq $BEFORE ]] && clean "All skills pass reusability checks"
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}---${RESET}"
if [[ $ISSUES -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}Overall: CLEAN${RESET} — no issues found"
  exit 0
else
  echo -e "${RED}${BOLD}Overall: NEEDS ATTENTION${RESET} — $ISSUES issue(s) found"
  exit 1
fi
