# Source ~/.profile if it exists
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Ensure XDG directories exist
() {
    local -a dirs=(
        "$XDG_CACHE_HOME"/{zsh,less,oh-my-posh}
        "$XDG_STATE_HOME"/{zsh,less}
        "$XDG_DATA_HOME/zinit"
    )
    for dir in $dirs; do
        [[ -d "$dir" ]] || mkdir -p "$dir"
    done
}

# Ensure path arrays don't contain duplicates
typeset -U PATH path

# Zinit configuration
export ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"

# Set tmux configuration
export TMUX_CONF="$XDG_CONFIG_HOME/tmux/tmux.conf"

# Oh My Posh cache config
export OH_MY_POSH_CACHE_DIR="$XDG_CACHE_HOME/oh-my-posh"
export POSH_CACHE_TIMEOUT=60

# SSH configuration
export SSH_CONFIG_DIR="$XDG_CONFIG_HOME/ssh"
# GPG configuration
export GPG_TTY=$(tty)

# stm32 programmer path
export STM32_PRG_PATH="$XDG_DATA_HOME/STM32CubeIDE/programmer/bin"

# Zephyr configuration
export ZEPHYR_BASE="$HOME/UserWorkspace/zephyr-workspace/zephyr"
export ZEPHYR_SDK_INSTALL_DIR="$XDG_DATA_HOME/zephyr-sdk"

# Set the list of directories that Zsh searches for programs
path=(
    # development tools
    "$ZEPHYR_SDK_INSTALL_DIR/zephyr-sdk-0.17.2/sysroots/x86_64-pokysdk-linux/usr/bin"
    "$ZEPHYR_SDK_INSTALL_DIR/usr/bin"
    # local binaries
    "$HOME/.local/bin"
    $path
)

# Set less options and temporary directory
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export LESSKEYIN="$XDG_CONFIG_HOME/less/lesskey"
export LESSKEYOUT="$XDG_CACHE_HOME/less/lesskey"
export LESSKEY="$XDG_CACHE_HOME/less/lesskey"
