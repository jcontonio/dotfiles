# Tmux Setup

This setup is designed to work with chezmoi with no manual tmux plugin steps.

1. Apply dotfiles:

```zsh
chezmoi apply
```

2. Start tmux:

```zsh
tmux
```

On first launch, tmux bootstraps TPM and installs configured plugins automatically.

## Core Usage

The tmux prefix key is `Ctrl+a`.

| Action                          | Shortcut / Command                                         |
| ------------------------------- | ---------------------------------------------------------- |
| New session                     | `tmux new -s <name>`                                       |
| List sessions                   | `tmux ls`                                                  |
| Attach to most recent session   | `tmux attach`                                              |
| Attach to named session         | `tmux attach -t <name>`                                    |
| Detach from current session     | `Ctrl+a d`                                                 |
| Kill named session              | `tmux kill-session -t <name>`                              |
| New window (tab)                | `Ctrl+a c`                                                 |
| Next window                     | `Ctrl+a n`                                                 |
| Previous window                 | `Ctrl+a p`                                                 |
| List/select window              | `Ctrl+a w`                                                 |
| Rename current window           | `Ctrl+a ,`                                                 |
| Split vertical (left/right)     | `Ctrl+a \|`                                                |
| Split horizontal (top/bottom)   | `Ctrl+a -`                                                 |
| Move between panes (prefixless) | macOS: `Command+Option+Arrow`, non-macOS: `Ctrl+Alt+Arrow` |
| Resize pane                     | `Ctrl+a h/j/k/l`                                           |
| Toggle pane zoom                | `Ctrl+a m`                                                 |
| Clear screen + tmux history     | macOS: `Command+k`, non-macOS: `Ctrl+k`                   |
| Reload tmux config              | `Ctrl+a R`                                                 |
| Show all key bindings           | `Ctrl+a ?`                                                 |

Note: `Ctrl+k` clear is bound after plugin initialization in `tmux.conf` so it overrides plugin keybindings.

## Navigation with Neovim

Primary navigation keys across Neovim splits (including file tree windows) and tmux panes:

- macOS: `Command + Option + Left/Right/Up/Down`
- Linux/non-macOS: `Control + Alt + Left/Right/Up/Down`

Fallback Neovim navigation remains available:

- `Control + h/j/k/l`

For macOS terminals, configure `Command + Option + Arrow` to send `Control + Alt + Arrow` escape sequences to tmux.

## Session Workflow Example

```zsh
# Create a work session
tmux new -s work

# Detach and leave it running
# (inside tmux) Ctrl+a d

# Reattach later
tmux attach -t work
```

## Saving Sessions

If you mean "keep my session so I can come back later today", tmux already does that.

- Detach: `Ctrl+a d`
- Reattach: `tmux attach -t <name>`

Your session remains until tmux server exits (or you kill that session).

If you mean "persist across reboot", this config uses `tmux-resurrect` + `tmux-continuum`.

- Manual save: `Ctrl+a Ctrl-s`
- Manual restore: `Ctrl+a Ctrl-r`
- Auto-save: handled by `tmux-continuum`
- Auto-restore on tmux start: enabled

## Cheat Sheet

- [tmuxcheatsheet.com](https://tmuxcheatsheet.com/)
