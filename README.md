
# Jay's dotfiles

* [macOS Specific](#macos)
* [ZSH setup](#zsh-setup)

## macOS

Change the screenshot location:

```zsh
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
killall SystemUIServer
```

Now drag that Screenshots folder from the Finder to your Dock. Now you have super fast drag'n'drop access to screenshots! Adjust the sorting to your liking.

## ZSH Setup

This is all assuming you’re running [iTerm2](https://iterm2.com/)

1. Install xCode command line tools
  ```zsh
  xcode-select --install
  ```
2. Install Homebrew
  ```zsh
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  ```
3. Install the [iTerm2 color theme](./iterm2/coolnight.itermcolors)
4. Install Oh-my-ZSH
  ```zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  ```
5. Link your .zshrc to the one in the repo
  ```zsh
  ln -s ~/dotfiles/zshrc ~/.zshrc
  source ~/.zshrc
  ```
6. Install PowerLevel10k theme
  * If you’re not on macOS and iTerm2, you’ll want to [install the Nerd Fonts first](https://github.com/romkatv/powerlevel10k#fonts). The fonts will be installed automatically with the theme script otherwise.

  ```zsh
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  ```

## Neovim Setup

1. Install Neovim
  ```zsh
  brew install neovim ripgrep
  ```
2. Create the nvim config directory if it doesn't exist already
  ```zsh
  mkdir ~/.config/nvim
  ```
3. Link the config
  ```zsh
  # optional but recommended
  mv ~/.local/share/nvim ~/.local/share/nvim.bak
  mv ~/.local/state/nvim ~/.local/state/nvim.bak
  mv ~/.cache/nvim ~/.cache/nvim.bak
  ln -s ~/dotfiles/config/nvim/init.lua ~/.config/nvim/init.lua
  ln -s ~/dotfiles/config/nvim/lua ~/.config/nvim/lua
  ```
4. Open `nvim`
5. It is recommended to run `:checkhealth` after installation

## Tmux Setup

5. Install tmux
  `brew install tmux`

Now you can open up projects in vim and use `,t` for Command-T, and `,n` for NerdTree.

## Tmux
```
ln -s ~/dotfiles/config/tmux/tmux.conf ~/.config/tmux.conf
ln -s ~/dotfiles/config/tmux ~/.config/tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux
tmux source ~/.tmux.conf
```

Inside tmux, hit control-a, shift-i. This will install all the plugins.
