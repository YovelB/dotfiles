# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure yout have the following installed on your system

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
$ git clone git@github.com:YovelB/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks inside dotfiles

```
$ stow .
```
