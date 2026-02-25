# Setup and Tips for macOS

1. Install xCode command line tools

```zsh
xcode-select --install
```

2. Change the screenshot location:

```zsh
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
killall SystemUIServer
```

Now drag that Screenshots folder from the Finder to your Dock. Now you have super fast drag'n'drop access to screenshots! Adjust the sorting to your liking.
