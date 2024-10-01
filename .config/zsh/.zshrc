# Zsh specific XDG directories
[ -d "$XDG_CACHE_HOME/zsh" ] || mkdir -p "$XDG_CACHE_HOME/zsh"
[ -d "$XDG_STATE_HOME/zsh" ] || mkdir -p "$XDG_STATE_HOME/zsh"

# History configuration
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion configuration
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Start tmux on terminal startup
if [ -z "$TMUX" ]; then tmux -f "$TMUX_CONF"; fi

# Add access to binaries in $HOME/.local/bin $CARGO_BIN_HOME
export PATH="$PATH:$HOME/.local/bin"

# Zinit setup
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
zinit cdreplay -q

# Prompt engine
eval "$(oh-my-posh init zsh --config ${XDG_CONFIG_HOME}/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias vim=nvim
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias ssh="ssh -F $SSH_CONFIG_DIR/config"

# Shell integration
# fzf
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
# zoxide
eval "$(zoxide init --cmd cd zsh)"

# Uncomment if you want to use GitHub Copilot CLI
# eval "$(gh copilot alias -- zsh)"

# Uncomment if you want to source a local configuration file
# [ -f ${ZDOTDIR:-$HOME}/.zshrc.local ] && source ${ZDOTDIR:-$HOME}/.zshrc.local

# Custom functions can be added here
# Example: function mkcd() { mkdir -p "$1" && cd "$1" }
