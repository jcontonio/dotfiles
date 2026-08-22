# Jay's dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), organized into OS/distro-specific profiles.

- [Repo Structure](#repo-structure)
- [Getting Started](#getting-started)
  - [1. Install chezmoi](#1-install-chezmoi)
- [Profile Setup](#profile-setup)
  - [Omarchy (Arch)](#omarchy-arch)
    - [Laptop vs. Desktop](#laptop-vs-desktop)
  - [Fedora (DNF)](#fedora-dnf)
  - [macOS (Homebrew)](#macos-homebrew)
- [Daily chezmoi Workflow](#daily-chezmoi-workflow)
- [Additional Setup](#additional-setup)

---

## Repo Structure

```
profiles/
  omarchy/            # Arch-based Omarchy profile (laptop)
    dot_config/
    dot_local/
    dot_bashrc
    packages/
      pacman-packages
      aur-packages
    system/
  omarchy-desktop/    # Arch-based Omarchy profile (desktop)
    dot_config/
      anker/            # Anker PowerConf C200 camera settings script
    packages/
      pacman-packages
      aur-packages
    system/             # root-owned files, installed via system/install.sh
      99-anker-c200.rules
      anker-c200.service
      install.sh
      README.md
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

#### Laptop vs. Desktop

There are two Omarchy profiles so machine-specific config never mixes:

| Profile | `.chezmoiroot` | Machine |
| --- | --- | --- |
| `profiles/omarchy` | `profiles/omarchy` | Laptop (internal panel, fingerprint reader, portable external display) |
| `profiles/omarchy-desktop` | `profiles/omarchy-desktop` | Desktop |

`profiles/omarchy-desktop` starts empty by design. Nothing is inherited from the laptop
profile: set the root, then `chezmoi add` each file you want tracked on the desktop.

```bash
chezmoi add ~/.config/hypr/monitors.lua
chezmoi add ~/.bashrc
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
4. [NAS Access & Backups](./docs/nas-backups.md)
5. [Anker PowerConf C200 Camera](./profiles/omarchy-desktop/system/README.md) (desktop only)
