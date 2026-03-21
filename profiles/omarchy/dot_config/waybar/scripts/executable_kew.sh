#!/bin/bash
STATUS=$(playerctl --player=kew status 2>/dev/null)
METADATA=$(playerctl --player=kew metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)

if [ -n "$METADATA" ]; then
    if [ "$STATUS" = "Paused" ]; then
        echo "▶ $METADATA"
    else
        echo "⏸ $METADATA"
    fi
fi
