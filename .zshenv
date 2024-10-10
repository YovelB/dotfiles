# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Append binaries including oh-my-posh to path
export PATH="$PATH:$HOME/.local/bin"

# Set Zsh directory
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# Zinit configuration
export ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

# Set tmux configuration
export TMUX_CONF="${XDG_CONFIG_HOME}/tmux/tmux.conf"

# Oh My Posh cache config for better performance
export OH_MY_POSH_CACHE_DIR="$XDG_CACHE_HOME/oh-my-posh"
export POSH_CACHE_TIMEOUT=60

# Set XDG Directory paths for apps
# SSH
export SSH_CONFIG_DIR="$XDG_CONFIG_HOME/ssh"

# Environment variables
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Cargo and Rustup XDG Base Directory paths
export RUSTUP_HOME="$HOME/.rustup"
export RUSTUP_CONFIG_HOME="$XDG_CONFIG_HOME/rustup"
export RUSTUP_CACHE_HOME="$XDG_CACHE_HOME/rustup"
export CARGO_HOME="$HOME/.cargo"
export CARGO_CONFIG_HOME="$XDG_CONFIG_HOME/cargo"
export CARGO_DATA_HOME="$XDG_DATA_HOME/cargo"
export CARGO_BIN_HOME="$CARGO_DATA_HOME/bin"
export CARGO_CACHE_HOME="$XDG_CACHE_HOME/cargo"
