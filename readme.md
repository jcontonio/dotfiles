# My ZSH / VIM / TMUX setup

**Before cloning this repo, do the following**

1. Install Homebrew

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2. Install Oh-my-ZSH

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

3. Install Spaceship theme

`curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh | zsh`

4. Install tmux

`brew install tmux`

5. Install rbenv w/ whatever version you want for system (important for vim install) (2.3.3)

```
brew install rbenv
rbenv install 2.3.3
```

6. Install coreutils

```
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
brew install coreutils
```

7. Install vim with custom ruby (2.3.3). This is to match the ruby version for the compiled Command-T vim plugin

`brew install vim --with-custom-ruby`

8. Install Powerline fonts

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

3. Set iTerm 2's font to a Powerline font (I am using Source Code Pro for Powerline)

4. Link the following to ~/.config:

```
# Setup ZSH
ln -s ~/.config/zshrc ~.zshrc
source ~/.zshrc

# Setup vim
ln -s ~/.config/vim/vimrc ~/.vimrc
ln -s ~/.config/vim ~/.vim
```
