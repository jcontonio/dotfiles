# Jay's dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), organized into OS/distro-specific profiles.

- [Repo Structure](#repo-structure)
- [Getting Started](#getting-started)
  - [1. Install chezmoi](#1-install-chezmoi)
- [Profile Setup](#profile-setup)
  - [Omarchy (Arch)](#omarchy-arch)
  - [Fedora (DNF)](#fedora-dnf)
  - [macOS (Homebrew)](#macos-homebrew)
- [Daily chezmoi Workflow](#daily-chezmoi-workflow)
- [Additional Setup](#additional-setup)

---

## Repo Structure

```
profiles/
  omarchy/          # Arch-based Omarchy profile
    dot_config/
    packages/
      pacman-packages
      aur-packages
  fedora/           # Fedora profile
    dot_config/
    dot_zshrc
    packages/
      dnf-packages
    scripts/
      fedora/
        dnf-hooks/
          snapper.actions
        install-dnf-snapper-hooks.sh
  macos/            # macOS profile
    dot_config/
    dot_zshrc
    packages/
      Brewfile
docs/
README.md
```

---

## Getting Started

1. Install chezmoi
2. Init Chezmoi (without applying!)
  ```bash
  chezmoi --init git@github.com:$GITHUB_USERNAME
  ```
3. Create a `.chezmoiroot` file pointing to your profile
  ```sh
  profiles/fedora
```

---

## Profile Setup

### Omarchy (Arch)

Install packages with pacman and your AUR helper of choice:

```bash
sudo pacman -S --needed - < profiles/omarchy/packages/pacman-packages
```

### Fedora (DNF)

**Enable RPM Fusion:**

```bash
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group upgrade core
```

**Enable Flathub:**

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

**Install packages:**

```bash
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y --skip-unavailable $(awk '!/^[[:space:]]*(#|$)/ { print }' profiles/fedora/packages/dnf-packages)

# Install gitmux from GitHub
GITMUX_VERSION=$(curl -s https://api.github.com/repos/arl/gitmux/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sL "https://github.com/arl/gitmux/releases/download/${GITMUX_VERSION}/gitmux_${GITMUX_VERSION}_linux_amd64.tar.gz" | sudo tar -xz -C /usr/local/bin gitmux
```

### macOS (Homebrew)

**Install from Brewfile:**

```bash
brew bundle --file profiles/macos/packages/Brewfile
```

**Refresh Brewfile from current machine:**

```bash
brew bundle dump --force --file profiles/macos/packages/Brewfile
```

> Note: `brew bundle dump` may include `vscode` extension entries if VS Code is installed.

---

## Daily chezmoi Workflow

Once initialized, chezmoi knows which profile is active. All standard commands work as expected:

```bash
chezmoi cd              # jump into the active profile's source directory
chezmoi edit ~/.zshrc   # edit a managed file
chezmoi re-add ~/.zshrc # pull local changes back into the source
chezmoi diff            # preview pending changes
chezmoi apply           # apply source to home directory
```

To switch profiles (e.g. moving to a new machine), just change the root `.chezmoiroot` file.

---

## Additional Setup

1. [Shell Setup](./docs/shell.md)
2. [tmux Setup](./docs/tmux.md)
3. [Setup and Tips for macOS](./docs/macos.md)
