#!/bin/sh
# Install the system-level half of the Anker C200 setup (udev rule + service unit).
# The settings script itself is managed by chezmoi at ~/.config/anker/c200-settings.sh
# and is NOT installed by this script.
#
# Run as your normal user; it re-invokes sudo where needed.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT="$HOME/.config/anker/c200-settings.sh"

if [ ! -x "$SCRIPT" ]; then
	echo "error: $SCRIPT missing or not executable — run 'chezmoi apply' first" >&2
	exit 1
fi

if [ ! -x /usr/local/bin/anker-powerconf-c200-linux-tools ]; then
	echo "error: anker-powerconf-c200-linux-tools not installed — see README.md" >&2
	exit 1
fi

# The unit needs an absolute path, and $HOME differs per machine/user, so the
# placeholder is substituted at install time rather than committed resolved.
sed "s|__SCRIPT__|$SCRIPT|" "$HERE/anker-c200.service" |
	sudo tee /etc/systemd/system/anker-c200.service >/dev/null

sudo install -m 0644 "$HERE/99-anker-c200.rules" /etc/udev/rules.d/99-anker-c200.rules

sudo systemctl daemon-reload
sudo udevadm control --reload-rules

echo "Installed. Re-plug the camera, or run: sudo systemctl start anker-c200.service"
