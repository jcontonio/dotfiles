# Random macOS tips / setup stuff that I recommend

**Change the screenshot location**

```
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
killall SystemUIServer
```

Now drag that Screenshots folder from the Finder to your Dock. Now you have super fast drag'n'drop access to screenshots! Adjust the sorting to your liking. 

# My ZSH / VIM / TMUX setup

**Before cloning this repo, do the following**

1. Install xCode command line tools

`xcode-select --install`

2. Install Homebrew

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3. Install Oh-my-ZSH

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

4. Install Spaceship theme

`curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh | zsh`

5. Install tmux

`brew install tmux`

6. Install rbenv w/ whatever version you want for system (important for vim install) (2.3.3)

```
brew install rbenv
rbenv install 2.3.3
rbenv global 2.3.3
```

7. Install coreutils

```
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
brew install coreutils
```

7. Install vim with custom ruby (2.3.3). This is to match the ruby version for the compiled Command-T vim plugin

`brew install vim --with-custom-ruby`

9. Install Powerline fonts

```
# clone
cd ~/Downloads
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts
```

## Linking the config

1. Clone the dotfiles repo

`git clone git@github.com:jcontonio/dotfiles.git ~/.config`

2. Install the Nord theme for iTerm 2 (located in ~/.config/iterm2)

3. in iTerm, apply PowerLine for Regular Font and Non-ASCII Font by clicking each Change Font button and select the PowerLine font.

4. Link the following to ~/.config:

```
# Setup ZSH
ln -s ~/.config/zshrc ~/.zshrc
source ~/.zshrc
```

## Vim

```
# Setup vim
ln -s ~/.config/vim/vimrc ~/.vimrc
ln -s ~/.config/vim ~/.vim
```

### Install plugins

1. Open vim `vim`
2. Run PlugClean and PlugInstall, then compile Command-T

```
# From vim
:PlugClean
:PlugInstall

# Compile Command-T
cd ~/.vim/plugged/command-t/ruby/command-t/ext/command-t
ruby extconf.rb
make
```

Now you can open up projects in vim and use `,t` for Command-T, and `,n` for NerdTree.

## Tmux
```
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
ln -s ~/.config/tmux ~/.tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
tmux source ~/.tmux.conf
```

Inside tmux, hit control-a, shift-i. This will install all the plugins.

## VSCode

Link the settings, keybindings, and snippets

```
ln -s ~/.config/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.config/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.config/vscode/snippets/ ~/Library/Application\ Support/Code/User/snippets
```
