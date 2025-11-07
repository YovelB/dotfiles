# source bash configuration if running bash
if [ -n "$BASH_VERSION" ]; then
  # source .bashrc for interactive shells
  if [ -f "$XDG_CONFIG_HOME/bash/.bashrc" ]; then
    . "$XDG_CONFIG_HOME/bash/.bashrc"
  fi

  # source .bash_profile for login shells
  if [ -f "$XDG_CONFIG_HOME/bash/.bash_profile" ]; then
    . "$XDG_CONFIG_HOME/bash/.bash_profile"
  fi

  # set history file location
  export HISTFILE="$XDG_CONFIG_HOME/bash/.bash_history"

  # source .bash_logout on exit
  if [ -f "$XDG_CONFIG_HOME/bash/.bash_logout" ]; then
    trap ". $XDG_CONFIG_HOME/bash/.bash_logout" EXIT
  fi
fi

# set default permissions
umask 022

# environment variables
export EDITOR="nvim"
export SYSTEMD_EDITOR="$EDITOR"
export VISUAL="$EDITOR"
