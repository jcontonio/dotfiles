#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SRC="${SOURCE_DIR}/dnf-hooks/snapper.actions"
HOOK_DST_DIR="/etc/dnf/libdnf5-plugins/actions.d"
HOOK_DST="${HOOK_DST_DIR}/snapper.actions"

if [[ ! -f "${HOOK_SRC}" ]]; then
  echo "Missing hook file: ${HOOK_SRC}" >&2
  exit 1
fi

if ! command -v dnf >/dev/null 2>&1; then
  echo "dnf not found; this script is for Fedora systems." >&2
  exit 1
fi

if ! command -v snapper >/dev/null 2>&1; then
  echo "snapper not found. Install it first: sudo dnf install -y snapper" >&2
  exit 1
fi

if ! rpm -q libdnf5-plugin-actions >/dev/null 2>&1; then
  echo "libdnf5-plugin-actions is not installed. Install it first:" >&2
  echo "  sudo dnf install -y libdnf5-plugin-actions" >&2
  exit 1
fi

if ! snapper list-configs | awk '{print $1}' | grep -qx 'root'; then
  echo "Snapper config 'root' not found. Create it first:" >&2
  echo "  sudo snapper -c root create-config /" >&2
  exit 1
fi

if [[ ! -f "/etc/dnf/libdnf5-plugins/actions.conf" ]]; then
  echo "Warning: dnf5 actions plugin config not found at /etc/dnf/libdnf5-plugins/actions.conf" >&2
  echo "Install/enable the dnf5 actions plugin before relying on hooks." >&2
fi

echo "Installing DNF5 actions hook to ${HOOK_DST}"
# Avoid forcing directory permissions if it already exists.
if sudo test -d "${HOOK_DST_DIR}"; then
  sudo install -m 0644 "${HOOK_SRC}" "${HOOK_DST}"
else
  sudo install -d "${HOOK_DST_DIR}"
  sudo install -m 0644 "${HOOK_SRC}" "${HOOK_DST}"
fi

echo "Done. Verify with:"
echo "  sudo dnf -v upgrade --refresh"
echo "Then inspect snapshots with:"
echo "  sudo snapper -c root list"
