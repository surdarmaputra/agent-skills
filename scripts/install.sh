#!/usr/bin/env bash
# install.sh — install or update agent skills
#
# Usage:
#   Install one skill globally:       ./scripts/install.sh grill-me
#   Install multiple skills globally: ./scripts/install.sh grill-me code-review-enhanced
#   Install all skills globally:      ./scripts/install.sh --all
#   Install to current project:       ./scripts/install.sh --project grill-me
#   Install all to current project:   ./scripts/install.sh --project --all
#   List available skills:            ./scripts/install.sh --list
#   Update already-installed skills:  ./scripts/install.sh --update
#
# Re-running install on an already-installed skill updates it (same command).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
info() { echo -e "  ${YELLOW}→${RESET}  $*"; }
err()  { echo -e "  ${RED}✗${RESET}  $*"; }

usage() {
  echo ""
  echo -e "${BOLD}Usage:${RESET}"
  echo "  $0 [--project] <skill-name> [skill-name ...]   Install specific skill(s)"
  echo "  $0 [--project] --all                           Install all skills"
  echo "  $0 [--project] --update                        Update all already-installed skills"
  echo "  $0 --list                                      List available skills"
  echo ""
  echo -e "${BOLD}Flags:${RESET}"
  echo "  --project    Install to .claude/skills/ in the current directory (project-local)"
  echo "               Default: install to ~/.claude/skills/ (global)"
  echo "  --all        Install every skill in the library"
  echo "  --update     Re-install skills already present in the target directory"
  echo "  --list       Print available skill names and exit"
  echo ""
}

list_available() {
  echo ""
  echo -e "${BOLD}Available skills:${RESET}"
  for dir in "$SKILLS_SRC"/*/; do
    name="$(basename "$dir")"
    if [[ -f "$dir/SKILL.md" ]]; then
      desc=$(grep -m1 "^description:" "$dir/SKILL.md" 2>/dev/null \
             | sed 's/^description: *//' | tr -d '"' | cut -c1-80 || echo "")
      printf "  %-30s %s\n" "$name" "$desc"
    fi
  done
  echo ""
}

install_skill() {
  local name="$1"
  local dest="$2"
  local src="$SKILLS_SRC/$name"

  if [[ ! -d "$src" ]]; then
    err "$name — not found in skills/"
    return 1
  fi

  mkdir -p "$dest"
  cp -r "$src" "$dest/"
  ok "$name → $dest/$name"
}

# ── Parse args ───────────────────────────────────────────────────────────────

PROJECT=false
MODE="named"   # named | all | update | list
SKILLS=()

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)  PROJECT=true; shift ;;
    --all)      MODE="all"; shift ;;
    --update)   MODE="update"; shift ;;
    --list)     MODE="list"; shift ;;
    --help|-h)  usage; exit 0 ;;
    -*)         err "Unknown flag: $1"; usage; exit 1 ;;
    *)          SKILLS+=("$1"); shift ;;
  esac
done

# ── Resolve destination ──────────────────────────────────────────────────────

if [[ "$PROJECT" == true ]]; then
  DEST="$(pwd)/.claude/skills"
  DEST_LABEL="project (.claude/skills/)"
else
  DEST="$HOME/.claude/skills"
  DEST_LABEL="global (~/.claude/skills/)"
fi

# ── Execute ──────────────────────────────────────────────────────────────────

case "$MODE" in

  list)
    list_available
    exit 0
    ;;

  all)
    echo ""
    echo -e "${BOLD}Installing all skills → $DEST_LABEL${RESET}"
    for dir in "$SKILLS_SRC"/*/; do
      name="$(basename "$dir")"
      [[ -f "$dir/SKILL.md" ]] && install_skill "$name" "$DEST"
    done
    ;;

  update)
    echo ""
    echo -e "${BOLD}Updating installed skills in $DEST_LABEL${RESET}"
    if [[ ! -d "$DEST" ]]; then
      err "No skills directory found at $DEST — nothing to update."
      exit 1
    fi
    updated=0
    for dir in "$DEST"/*/; do
      name="$(basename "$dir")"
      if [[ -d "$SKILLS_SRC/$name" ]]; then
        install_skill "$name" "$DEST"
        updated=$((updated + 1))
      else
        info "$name — not in library, skipped"
      fi
    done
    [[ $updated -eq 0 ]] && info "No matching skills found to update."
    ;;

  named)
    if [[ ${#SKILLS[@]} -eq 0 ]]; then
      err "No skill names provided."
      usage
      exit 1
    fi
    echo ""
    echo -e "${BOLD}Installing skills → $DEST_LABEL${RESET}"
    for name in "${SKILLS[@]}"; do
      install_skill "$name" "$DEST"
    done
    ;;

esac

echo ""
echo -e "${BOLD}Done.${RESET} Invoke with a slash command in Claude Code, e.g. /${SKILLS[0]:-<skill-name>}"
echo ""
