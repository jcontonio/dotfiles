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

## Navigation with Neovim

Primary navigation keys across Neovim splits (including file tree windows) and tmux panes:

- macOS: `Command + Option + Left/Right/Up/Down`
- Linux/non-macOS: `Control + Alt + Left/Right/Up/Down`

Fallback navigation keys in Neovim remain available by default:

- `Control + h/j/k/l`

For macOS terminals, configure `Command + Option + Arrow` to send `Control + Alt + Arrow` escape sequences to tmux.
