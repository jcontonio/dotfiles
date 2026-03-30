#!/bin/bash
set -e
sudo cp "$HOME/.local/share/chezmoi/profiles/omarchy/system/restart-fprintd-after-suspend.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now restart-fprintd-after-suspend.service
