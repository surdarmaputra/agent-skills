#!/usr/bin/env bash
# install-remote.sh — install agent skills without cloning the repo
#
# Uses a sparse git checkout under the hood: only downloads the files
# for the skills you request — no full repo clone needed.
#
# Usage (pipe from curl):
#   bash <(curl -fsSL https://raw.githubusercontent.com/surdarmaputra/agent-skills/main/scripts/install-remote.sh) grill-me
#   bash <(curl -fsSL ...) grill-me code-review-enhanced
#   bash <(curl -fsSL ...) --all
#   bash <(curl -fsSL ...) --project grill-me
#   bash <(curl -fsSL ...) --list
#   bash <(curl -fsSL ...) --update

set -euo pipefail

REPO_URL="https://github.com/surdarmaputra/agent-skills.git"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
info() { echo -e "  ${YELLOW}→${RESET}  $*"; }
err()  { echo -e "  ${RED}✗${RESET}  $*"; }

# ── Temp workspace ────────────────────────────────────────────────────────────

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ── Sparse clone (fetches no blobs until sparse-checkout is set) ──────────────

setup_repo() {
  info "Fetching skill catalog..."
  git clone --depth 1 --filter=blob:none --sparse \
    "$REPO_URL" "$WORK/repo" -q 2>/dev/null
  cd "$WORK/repo"
  # Start with an empty checkout — blobs pulled only for paths we set next
  git sparse-checkout init --no-cone -q 2>/dev/null || true
  cd - > /dev/null
}

fetch_paths() {
  # $@ = sparse paths to materialise (e.g. "skills/grill-me")
  cd "$WORK/repo"
  git sparse-checkout set "$@" -q 2>/dev/null
  cd - > /dev/null
}

# ── Helpers ───────────────────────────────────────────────────────────────────

list_remote_skills() {
  setup_repo
  fetch_paths "skills"
  echo ""
  echo -e "${BOLD}Available skills:${RESET}"
  for dir in "$WORK/repo/skills"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    [[ -f "$dir/SKILL.md" ]] || continue
    desc=$(grep -m1 "^description:" "$dir/SKILL.md" 2>/dev/null \
           | sed 's/^description: *//' | tr -d '"' | cut -c1-80 || echo "")
    printf "  %-30s %s\n" "$name" "$desc"
  done
  echo ""
}

install_skill() {
  local name="$1"
  local dest="$2"
  local confirm="${3:-false}"   # true = prompt before replacing
  local src="$WORK/repo/skills/$name"
  local target="$dest/$name"

  if [[ ! -d "$src" ]] || [[ ! -f "$src/SKILL.md" ]]; then
    err "$name — not found in library"
    return 1
  fi

  if [[ -d "$target" ]] && [[ "$confirm" == true ]]; then
    printf "  %b→%b  %s already installed. Replace? [y/N] " "$YELLOW" "$RESET" "$name"
    if [[ "$YES" == true ]]; then
      echo "y (--yes)"
    else
      read -r reply
      [[ "$reply" =~ ^[Yy]$ ]] || { info "$name — skipped"; return 0; }
    fi
  fi

  mkdir -p "$dest"
  rm -rf "$target"
  cp -r "$src" "$target"
  ok "$name → $target"
}

# ── Parse args ────────────────────────────────────────────────────────────────

usage() {
  echo ""
  echo -e "${BOLD}Usage (pipe from curl):${RESET}"
  echo "  bash <(curl -fsSL <url>) [--project] <skill-name> [skill-name ...]"
  echo "  bash <(curl -fsSL <url>) [--project] --all"
  echo "  bash <(curl -fsSL <url>) [--project] --update"
  echo "  bash <(curl -fsSL <url>) --list"
  echo ""
  echo -e "${BOLD}Flags:${RESET}"
  echo "  --project    Install to .claude/skills/ in the current directory (project-local)"
  echo "               Default: install to ~/.claude/skills/ (global)"
  echo "  --all        Install every skill in the library"
  echo "  --update     Re-install skills already present in the target directory"
  echo "  --list       Print available skill names and exit"
  echo "  --yes, -y    Skip confirmation prompts (non-interactive / scripting)"
  echo ""
}

PROJECT=false
MODE="named"
YES=false
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
    --yes|-y)   YES=true; shift ;;
    --help|-h)  usage; exit 0 ;;
    -*)         err "Unknown flag: $1"; usage; exit 1 ;;
    *)          SKILLS+=("$1"); shift ;;
  esac
done

# ── Resolve destination ───────────────────────────────────────────────────────

if [[ "$PROJECT" == true ]]; then
  DEST="$(pwd)/.claude/skills"
  DEST_LABEL="project (.claude/skills/)"
else
  DEST="$HOME/.claude/skills"
  DEST_LABEL="global (~/.claude/skills/)"
fi

# ── Execute ───────────────────────────────────────────────────────────────────

case "$MODE" in

  list)
    list_remote_skills
    exit 0
    ;;

  all)
    echo ""
    echo -e "${BOLD}Installing all skills → $DEST_LABEL${RESET}"
    setup_repo
    fetch_paths "skills"
    for dir in "$WORK/repo/skills"/*/; do
      name="$(basename "$dir")"
      [[ -f "$dir/SKILL.md" ]] && install_skill "$name" "$DEST" false
    done
    ;;

  update)
    echo ""
    echo -e "${BOLD}Updating installed skills in $DEST_LABEL${RESET}"
    if [[ ! -d "$DEST" ]]; then
      err "No skills directory found at $DEST — nothing to update."
      exit 1
    fi
    INSTALLED=()
    for dir in "$DEST"/*/; do
      [[ -d "$dir" ]] || continue
      INSTALLED+=("$(basename "$dir")")
    done
    if [[ ${#INSTALLED[@]} -eq 0 ]]; then
      info "No installed skills found."
      exit 0
    fi
    setup_repo
    sparse_paths=()
    for name in "${INSTALLED[@]}"; do
      sparse_paths+=("skills/$name")
    done
    fetch_paths "${sparse_paths[@]}"
    updated=0
    for name in "${INSTALLED[@]}"; do
      if [[ -d "$WORK/repo/skills/$name" ]]; then
        install_skill "$name" "$DEST" false
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
    setup_repo
    sparse_paths=()
    for name in "${SKILLS[@]}"; do
      sparse_paths+=("skills/$name")
    done
    fetch_paths "${sparse_paths[@]}"
    for name in "${SKILLS[@]}"; do
      install_skill "$name" "$DEST" true
    done
    ;;

esac

echo ""
echo -e "${BOLD}Done.${RESET} Invoke with a slash command in Claude Code, e.g. /${SKILLS[0]:-<skill-name>}"
echo ""
