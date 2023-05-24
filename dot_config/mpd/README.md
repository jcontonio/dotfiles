# Set up MPD

Modified version of this: https://gist.github.com/lirenlin/f92c8e849530ebf66604

```zsh
sudo dnf install mpd mpc ncmpcpp
mkdir ~/.mpd

touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpdstate}

ln -s ~/dotfiles/config/mpd/mpd.conf ~/.mpd/mpd.conf
```

Update the library

```zsh
mpc update --wait
```

# Set up NCMPCPP

```
mkdir ~/.ncmpcpp
ln -s ~/dotfiles/config/ncmpcpp/config ~/.ncmpcpp/config

ncmpcpp
```
