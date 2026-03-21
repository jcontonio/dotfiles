#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# use-profile.sh
# Initialize or switch chezmoi to a dotfile profile.
#
# Usage: ./use-profile.sh
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"

# ── Sanity checks ────────────────────────────

if [[ -z "$REPO_ROOT" ]]; then
  echo "Error: could not determine repo root. Is this script inside a git repo?" >&2
  exit 1
fi

PROFILES_DIR="$REPO_ROOT/profiles"

if [[ ! -d "$PROFILES_DIR" ]]; then
  echo "Error: profiles/ directory not found at $REPO_ROOT" >&2
  exit 1
fi

# ── Discover available profiles ──────────────

mapfile -t PROFILES < <(find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

if [[ ${#PROFILES[@]} -eq 0 ]]; then
  echo "Error: no profiles found in $PROFILES_DIR" >&2
  exit 1
fi

# ── Interactive profile selection ────────────

echo ""
echo "Available profiles:"
echo ""
for i in "${!PROFILES[@]}"; do
  printf "  [%s] %s\n" "$((i + 1))" "${PROFILES[$i]}"
done
echo ""

while true; do
  read -rp "Select a profile (1-${#PROFILES[@]}): " SELECTION
  if [[ "$SELECTION" =~ ^[0-9]+$ ]] && (( SELECTION >= 1 && SELECTION <= ${#PROFILES[@]} )); then
    PROFILE="${PROFILES[$((SELECTION - 1))]}"
    break
  else
    echo "Invalid selection. Enter a number between 1 and ${#PROFILES[@]}."
  fi
done

PROFILE_SOURCE="$PROFILES_DIR/$PROFILE"
echo ""
echo "→ Profile: $PROFILE"
echo "→ Source:  $PROFILE_SOURCE"
echo ""

# ── Detect current chezmoi state ─────────────

CHEZMOI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"

if [[ ! -f "$CHEZMOI_CONFIG" ]]; then
  # ── First-time init ──────────────────────────
  echo "chezmoi is not initialized. Running first-time init..."
  echo ""
  mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi"
  chezmoi init --source "$PROFILE_SOURCE"
  echo ""
  echo "chezmoi initialized with profile '$PROFILE'."

else
  CURRENT_SOURCE="$(chezmoi source-path 2>/dev/null || true)"

  if [[ "$CURRENT_SOURCE" == "$PROFILE_SOURCE" ]]; then
    echo "Already using profile '$PROFILE'. Nothing to do."
    exit 0
  fi

  # ── Switch profiles ──────────────────────────
  echo "chezmoi is currently pointing at:"
  echo "  $CURRENT_SOURCE"
  echo ""
  echo "Switching to profile '$PROFILE' will update chezmoi's source"
  echo "directory. Your home directory files will not be touched until"
  echo "you run 'chezmoi apply'."
  echo ""
  read -rp "Proceed? [y/N] " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  chezmoi init --source "$PROFILE_SOURCE"
  echo ""
  echo "Switched to profile '$PROFILE'."
fi

# ── Post-action prompt ───────────────────────

echo ""
echo "What would you like to do next?"
echo ""
echo "  [1] chezmoi diff   (preview what would change)"
echo "  [2] chezmoi apply  (apply dotfiles to home)"
echo "  [3] Nothing, exit"
echo ""
read -rp "Selection [1-3]: " NEXT

case "$NEXT" in
  1) echo ""; chezmoi diff ;;
  2)
    echo ""
    read -rp "Run 'chezmoi apply'? This will modify your home directory. [y/N] " APPLY_CONFIRM
    if [[ "$APPLY_CONFIRM" =~ ^[Yy]$ ]]; then
      chezmoi apply
      echo ""
      echo "Done."
    else
      echo "Skipped."
    fi
    ;;
  *) echo "Exiting." ;;
esac
