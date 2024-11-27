# Enable profiling if needed
# zmodload zsh/zprof

# History configuration
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Tmux startup (only if not in VS Code and tmux isn't running)
[[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]] && exec tmux -f "$TMUX_CONF"

# Load completions more efficiently
() {
    # Load completion system
    autoload -Uz compinit

    # Setup completion cache path
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
    
    # Define dump file location
    local dump_file="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
    
    # Only regenerate dump file once per hour
    if [[ -f "$dump_file" && (! -f "$dump_file.zwc" || "$dump_file" -nt "$dump_file.zwc") ]]; then
        zcompile "$dump_file"
    fi
    
    # Load dump file, regenerate if older than 1 hour
    if [[ -f "$dump_file"(#qN.mh+1) ]]; then
        compinit -d "$dump_file"
    else
        compinit -C -d "$dump_file"
    fi
}

# Basic completion styling (before plugins)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Initialize Zinit
() {
    if [[ ! -d "$ZINIT_HOME" ]]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    fi
    source "${ZINIT_HOME}/zinit.zsh"
}

# Plugin loading with improved timing
zinit ice wait"0" lucid
zinit light zsh-users/zsh-completions

zinit ice wait"1" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Load fzf-tab before syntax highlighting
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# Syntax highlighting loaded last
zinit ice wait"2" lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
zinit light zsh-users/zsh-syntax-highlighting

# Turbo load snippets
zinit ice wait"1" lucid
zinit snippet OMZP::git

zinit ice wait"1" lucid
zinit snippet OMZP::sudo

zinit ice wait"2" lucid
zinit snippet OMZP::command-not-found

# Lazy load shell integrations
() {
    local fzf_dir="/usr/share/fzf"
    if [[ -d $fzf_dir ]]; then
        source "$fzf_dir/key-bindings.zsh"
        source "$fzf_dir/completion.zsh"
    fi
}

# Initialize zoxide
() {
    (( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"
}

# Load completions
zinit cdreplay -q

# Prompt engine (keep this non-lazy as requested)
eval "$(oh-my-posh init zsh --config ${XDG_CONFIG_HOME}/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# FZF-tab styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Function to load aliases
function load_aliases() {
    # Basic aliases
    alias vim=nvim
    alias c='clear'
    alias md='mkdir -p'
    alias ls='ls --color=auto'
    alias ll='ls -lah'
    alias grep='grep --color=auto'
}
load_aliases

# Copilot CLI
eval "$(gh copilot alias -- zsh)"

# Enable profiling output if needed
# zprof
