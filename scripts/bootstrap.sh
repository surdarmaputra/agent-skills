#!/usr/bin/env bash
# bootstrap.sh — set up the dev environment for this repo
# Idempotent: safe to run multiple times.
# Run manually:  bash scripts/bootstrap.sh
# Run via hook:  automatic on Claude Code SessionStart

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
info() { echo -e "  ${YELLOW}→${RESET}  $*"; }

echo ""
echo -e "${BOLD}## Bootstrap: agent-skills${RESET}"
echo ""

# ── 1. Lefthook ──────────────────────────────────────────────────────────────

if command -v lefthook &>/dev/null; then
  ok "lefthook already installed ($(lefthook version 2>/dev/null || echo 'unknown version'))"
else
  info "Installing lefthook..."
  if command -v brew &>/dev/null; then
    brew install lefthook -q
    ok "lefthook installed via Homebrew"
  elif command -v npm &>/dev/null; then
    npm install -g @evilmartians/lefthook --silent
    ok "lefthook installed via npm"
  elif command -v curl &>/dev/null; then
    # Binary install fallback
    curl -fsSL https://raw.githubusercontent.com/evilmartians/lefthook/master/install.sh | bash
    ok "lefthook installed via install script"
  else
    echo -e "  ${YELLOW}⚠${RESET}  Could not install lefthook automatically."
    echo "     Install manually: https://github.com/evilmartians/lefthook#install"
  fi
fi

# ── 2. Activate git hooks ────────────────────────────────────────────────────

if command -v lefthook &>/dev/null; then
  lefthook install -f 2>/dev/null
  ok "lefthook hooks installed (.git/hooks/pre-push)"
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Ready.${RESET} Pre-push verification is active."
echo ""
