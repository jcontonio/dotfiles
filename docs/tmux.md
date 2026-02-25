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
| Reload tmux config              | `Ctrl+a r`                                                 |
| Show all key bindings           | `Ctrl+a ?`                                                 |

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

## Cheat Sheet

- [tmuxcheatsheet.com](https://tmuxcheatsheet.com/)
