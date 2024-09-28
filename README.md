# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system

### Git

```
sudo dnf install git
```

### Stow

```
sudo dnf install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone https://github.com/YovelB/dotfiles
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```
## Dependencies
#### 1. Tmux plugins
Clone and add the specified plugins in $HOME/.config/tmux/plugins folder.<br>
For example: TPM and tokyo-night theme plugins.
```
$ git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
$ git clone https://github.com/janoamaral/tokyo-night-tmux ~/.tmux/plugins/tokyo-night-tmux
```
