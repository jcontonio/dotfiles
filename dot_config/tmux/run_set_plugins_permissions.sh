#!/bin/bash

REPOSITORY="https://github.com/tmux-plugins/tpm"
DIRECTORY="$HOME/.config/tmux/plugins"

if [ ! -d "$DIRECTORY" ]; then
	if [ ! -L "$DIRECTORY" ]; then
		echo "Directory doesn't exist"
		mkdir -p -- "$DIRECTORY"
		chmod 770 "$DIRECTORY"
		git clone "$REPOSITORY" "$DIRECTORY/tpm"
	else
		chmod 770 "$DIRECTORY"
	fi
fi
