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
Clone TPM (Tmux plugin manager)
```
$ git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
Then run TPM installation command (prefix + I) to install the other plugins
