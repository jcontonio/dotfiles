# Shell Setup

Assuming we have zsh:

1. Install Oh-my-ZSH and plugins

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

2. Setup Chezmoi

```zsh
chezmoi init --apply $GITHUB_USERNAME
chezmoi apply
```

3. Install PowerLevel10k theme

- You’ll want to [install the Nerd Fonts first](https://github.com/romkatv/powerlevel10k#fonts). The fonts will be installed automatically with the theme script otherwise.

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

4. Run the config for p10k

```zsh
p10k configure
```
