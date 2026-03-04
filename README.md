# Jay's dotfiles

- [System Setup](#system-setup)
  - [macOS (Homebrew)](#macos-homebrew)
  - [Fedora (DNF)](#fedora-dnf)
- [Additional Setup](#additional-setup)

Personal dotfiles managed with `chezmoi`, with OS-specific templates and setup docs for quickly reproducing my shell, editor, tmux, and package environment on macOS and Linux.

## System Setup

### macOS (Homebrew)

The package source of truth is [`packages/macos/Brewfile`](./packages/macos/Brewfile).

1. Install from Brewfile:

```zsh
brew bundle --file packages/macos/Brewfile
```

2. Refresh Brewfile from current machine:

```zsh
brew bundle dump --force --file packages/macos/Brewfile
```

Note: `brew bundle dump` may include `vscode` extension entries if VS Code is installed.

### Fedora (DNF)

The package source of truth is [`packages/linux/dnf-packages`](./packages/linux/dnf-packages).

1. Enable RPM Fusion:

```zsh
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group upgrade core
```

2. Enable Flathub:

```zsh
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

3. Install curated Fedora package set:

```zsh
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y --skip-unavailable $(awk '!/^[[:space:]]*(#|$)/ { print }' packages/linux/dnf-packages)

# Install gitmux from GitHub
GITMUX_VERSION=$(curl -s https://api.github.com/repos/arl/gitmux/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sL "https://github.com/arl/gitmux/releases/download/${GITMUX_VERSION}/gitmux_${GITMUX_VERSION}_linux_amd64.tar.gz" | sudo tar -xz -C /usr/local/bin gitmux
```

---

## Additional Setup

1. [Shell Setup](./docs/shell.md)
2. [tmux Setup](./docs/tmux.md)
3. [Setup and Tips for macOS](./docs/macos.md)
