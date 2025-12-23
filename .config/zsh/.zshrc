# first load .zprofile
if [[ -f "$XDG_CONFIG_HOME/zsh/.zprofile" ]]; then
    source "$XDG_CONFIG_HOME/zsh/.zprofile"
fi

# enable profiling if needed
# zmodload zsh/zprof

# history configuration
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# tmux startup (only if not in VS Code and tmux isn't running)
[[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]] && exec tmux -f "$TMUX_CONF"

# load completions more efficiently
() {
    # load completion system
    autoload -Uz compinit

    # setup completion cache path
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

    # define dump file location
    local dump_file="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

    # only regenerate dump file once per hour
    if [[ -f "$dump_file" && (! -f "$dump_file.zwc" || "$dump_file" -nt "$dump_file.zwc") ]]; then
        zcompile "$dump_file"
    fi

    # load dump file, regenerate if older than 1 hour
    if [[ -f "$dump_file"(#qN.mh+1) ]]; then
        compinit -d "$dump_file"
    else
        compinit -C -d "$dump_file"
    fi
}

# basic completion styling (before plugins)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# initialize Zinit
() {
    if [[ ! -d "$ZINIT_HOME" ]]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    fi
    source "${ZINIT_HOME}/zinit.zsh"
}

# plugin loading with improved timing
zinit ice wait"0" lucid
zinit light zsh-users/zsh-completions

zinit ice wait"1" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# load fzf tab before syntax highlighting
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# syntax highlighting loaded last
zinit ice wait"2" lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
zinit light zsh-users/zsh-syntax-highlighting

# turbo load snippets
zinit ice wait"1" lucid
zinit snippet OMZP::git

zinit ice wait"1" lucid
zinit snippet OMZP::sudo

zinit ice wait"2" lucid
zinit snippet OMZP::command-not-found

# lazy load shell integrations
() {
    local fzf_dir="/usr/share/fzf"
    if [[ -d $fzf_dir ]]; then
        source "$fzf_dir/key-bindings.zsh"
        source "$fzf_dir/completion.zsh"
    fi
}

# initialize zoxide
() {
    (( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"
}

# load completions
zinit cdreplay -q

# prompt engine (keep this non-lazy as requested)
eval "$(oh-my-posh init zsh --config ${XDG_CONFIG_HOME}/ohmyposh/zen.toml)"

# keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# FZF tab styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# function to load aliases
function load_aliases() {
    # basic aliases
    alias vim=nvim
    alias md='mkdir -p'
    alias ls='ls --color=auto'
    alias ll='ls -lah'
    alias grep='grep --color=auto'
    alias zathura='zathura --mode=fullscreen'

    # task managment
    alias ttui='taskwarrior-tui'
    alias tbd='task burndown'

    # translate and dictionary aliases
    alias he="trans -b :he -shell"
    alias en="trans -b :en -shell"
  }
load_aliases

# init ssh agent with optional lifetime option -t 12h
eval "$(ssh-agent -s)" > /dev/null

# enable profiling output if needed
# zprof
