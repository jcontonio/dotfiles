#!/bin/bash
profile=$(powerprofilesctl get)
case "$profile" in
  performance) icon="󱐋" ;;
  power-saver) icon="󰌪" ;;
  balanced)    icon="󰾅" ;;
  *)           icon="󰍛" ;;
esac
echo "{\"text\": \"$icon\", \"tooltip\": \"Power profile: $profile\"}"
