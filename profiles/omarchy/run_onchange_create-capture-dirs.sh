#!/bin/bash
set -e
# omarchy-capture-screenrecording aborts if its output directory is missing,
# so create the dirs referenced by dot_config/uwsm/default.
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Videos/Screencasts"
