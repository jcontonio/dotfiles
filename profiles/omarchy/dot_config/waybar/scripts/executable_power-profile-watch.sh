#!/bin/bash
# Send SIGRTMIN+11 to waybar whenever the active power profile changes
dbus-monitor --system \
  "type='signal',interface='org.freedesktop.DBus.Properties',path='/net/hadess/PowerProfiles'" 2>/dev/null | \
awk '/ActiveProfile/ { system("pkill -SIGRTMIN+11 waybar"); fflush() }'
