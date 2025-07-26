# Source Bash configuration if running Bash
if [ -n "$BASH_VERSION" ]; then
  # Source .bashrc for interactive shells
  if [ -f "$XDG_CONFIG_HOME/bash/.bashrc" ]; then
    . "$XDG_CONFIG_HOME/bash/.bashrc"
  fi

  # Source .bash_profile for login shells
  if [ -f "$XDG_CONFIG_HOME/bash/.bash_profile" ]; then
    . "$XDG_CONFIG_HOME/bash/.bash_profile"
  fi

  # Set history file location
  export HISTFILE="$XDG_CONFIG_HOME/bash/.bash_history"

  # Source .bash_logout on exit
  if [ -f "$XDG_CONFIG_HOME/bash/.bash_logout" ]; then
    trap ". $XDG_CONFIG_HOME/bash/.bash_logout" EXIT
  fi
fi

# Added by Toolbox App
export PATH="$PATH:/home/yovel/.local/share/JetBrains/Toolbox/scripts"

# Set default permissions
umask 022

# Environment variables
export EDITOR="nvim"
export SYSTEMD_EDITOR="$EDITOR"
export VISUAL="$EDITOR"
