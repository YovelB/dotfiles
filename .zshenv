# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Set Zsh directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Set default permissions
umask 022

# Environment variables needed before .zprofile
export EDITOR="nvim"
export VISUAL="$EDITOR"
