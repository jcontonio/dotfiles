#!/usr/bin/env bash
#
# Runs on herdr's worktree.created event. Copies the files listed in the main
# checkout's .worktreeinclude into the new worktree, so each repository decides
# what it needs (for example its own mise.local.toml with its own GitHub account).
#
# .worktreeinclude uses .gitignore patterns, one per line. Claude Code reads the
# same file for its worktrees. Only untracked files are copied, and files that
# already exist in the worktree are left alone.
#
# If the main checkout has a .worktree-setup.sh, it runs last, from inside the
# new worktree, with WORKTREE_MAIN_ROOT and WORKTREE_PATH set.

set -euo pipefail

log() { printf 'worktree-setup: %s\n' "$1" >&2; }

event_json="${HERDR_PLUGIN_EVENT_JSON:-}"
log "event: ${event_json}"

# The payload's shape isn't documented, so find checkout_path wherever it is.
checkout_path=$(printf '%s' "$event_json" \
  | /usr/bin/jq -r '[.. | objects | .checkout_path? | strings] | first // empty')
if [[ -z "$checkout_path" || ! -d "$checkout_path" ]]; then
  log "no checkout_path in the event, nothing to do"
  exit 0
fi

# The first entry of `git worktree list` is always the main checkout.
main_root=$(git -C "$checkout_path" worktree list --porcelain | sed -n '1s/^worktree //p')
if [[ "$main_root" == "$checkout_path" ]]; then
  log "${checkout_path} is the main checkout, nothing to do"
  exit 0
fi

include_file="${main_root}/.worktreeinclude"
if [[ -f "$include_file" ]]; then
  while IFS= read -r -d '' file; do
    if [[ -e "${checkout_path}/${file}" ]]; then
      log "skipping ${file}: already in the worktree"
      continue
    fi
    mkdir -p "$(dirname "${checkout_path}/${file}")"
    cp -p "${main_root}/${file}" "${checkout_path}/${file}"
    log "copied ${file}"
  done < <(git -C "$main_root" ls-files -z --others --ignored --exclude-from="$include_file")
else
  log "no .worktreeinclude in ${main_root}, copying nothing"
fi

cd "$checkout_path"

if command -v mise >/dev/null; then
  for config in mise.toml .mise.toml mise.local.toml .mise.local.toml; do
    if [[ -f "$config" ]]; then
      mise trust --quiet "$config" && log "trusted ${config}"
    fi
  done
fi

if command -v direnv >/dev/null && [[ -f .envrc ]]; then
  direnv allow && log "allowed .envrc"
fi

# A repository's own extra steps, run from inside the new worktree.
setup_script="${main_root}/.worktree-setup.sh"
if [[ -f "$setup_script" ]]; then
  log "running ${setup_script}"
  WORKTREE_MAIN_ROOT="$main_root" WORKTREE_PATH="$checkout_path" bash "$setup_script" >&2
  log "finished ${setup_script}"
fi
