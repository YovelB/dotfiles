# source ~/.profile if it exists
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# ensure XDG dirs exist
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

# ensure path arrays dont contain duplicates
typeset -U PATH path


# Zinit config
export ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"

# set tmux config
export TMUX_CONF="$XDG_CONFIG_HOME/tmux/tmux.conf"

# oh my posh cache config
export OH_MY_POSH_CACHE_DIR="$XDG_CACHE_HOME/oh-my-posh"
export POSH_CACHE_TIMEOUT=60

# default editor
export EDITOR=nvim

# SSH config
export SSH_CONFIG_DIR="$XDG_CONFIG_HOME/ssh"
# GPG config
export GPG_TTY=$(tty)

# stm32 programmer path
export STM32_PRG_PATH="$XDG_DATA_HOME/STM32CubeIDE/programmer/bin"

# zephyr configuration
export ZEPHYR_BASE="$HOME/UserWorkspace/zephyr-workspace/zephyr"
export ZEPHYR_SDK_INSTALL_DIR="$XDG_DATA_HOME/zephyr-sdk"

# go config
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$GOPATH/pkg/mod"

# add to path so zsh searches for these programs
path=(
    # development tools
    "$ZEPHYR_SDK_INSTALL_DIR/zephyr-sdk-0.17.2/sysroots/x86_64-pokysdk-linux/usr/bin"
    "/opt/stm32cubeide/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.linux64_1.0.0.202410170706/tools/bin"
    "$ZEPHYR_SDK_INSTALL_DIR/usr/bin"
    # local binaries
    "/usr/bin"
    "$HOME/.local/bin"
    $path
)
