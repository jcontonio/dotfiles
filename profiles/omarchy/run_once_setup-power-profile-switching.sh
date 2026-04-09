#!/bin/bash
set -euo pipefail

# Write udev rule
sudo tee /etc/udev/rules.d/99-power-profile-switch.rules > /dev/null <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", ACTION=="change", RUN+="/usr/bin/powerprofilesctl set performance"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", ACTION=="change", RUN+="/usr/bin/powerprofilesctl set power-saver"
EOF

# Write systemd service
sudo tee /etc/systemd/system/power-profile-init.service > /dev/null <<'EOF'
[Unit]
Description=Set power profile based on AC state
After=power-profiles-daemon.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then powerprofilesctl set performance; else powerprofilesctl set power-saver; fi'

[Install]
WantedBy=multi-user.target
EOF

sudo udevadm control --reload-rules
sudo systemctl enable --now power-profile-init.service
