# Dotfiles

this repo contains config files (dotfiles) for my system.

## requirements

install the following tools:

- **Git**: version control system  
- **GNU Stow**: for managing symlinks  

## install

clone the repository into your `$HOME` directory:

```bash
git clone https://github.com/YovelB/dotfiles
cd dotfiles
```

use GNU Stow to create symlinks:

```bash
stow .
```

## usage

manage your system config by editing files in this repo.  
changes here will reflect in your system.

### dependencies

#### Tmux plugins

clone the Tmux Plugin Manager (TPM):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

install plugins using TPM (prefix + `I`).

#### performance measurement

measure shell startup time:

```bash
time zsh -i -c exit
```

for detailed profiling:

```bash
# Uncomment `zmodload zsh/zprof` at the top and `zprof` at the bottom
zsh -i -c exit
```
