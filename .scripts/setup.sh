#!/bin/bash
set -e

# stage: core shell and dotfiles

# setup dot files
if [ -d "$HOME/.dotfiles" ]; then
  cd "$HOME/.dotfiles"
  stow . --adopt
else
  echo "error: dotfiles dir not found, exiting"
  exit 1
fi

# secure ssh (maybe) for ssh daemon
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -f "$HOME/.ssh/config" ]; then
  chmod 644 "$HOME/.ssh/config"
fi

# copy pacman hooks
sudo mkdir -p /etc/pacman.d/hooks
sudo cp "$HOME/.dotfiles/system_config/pacman-hooks/50-uki-backup.hook" /etc/pacman.d/hooks/

# copy system configs
sudo mkdir -p /etc/greetd
sudo cp "$HOME/.dotfiles/system_config/greetd/config.toml" /etc/greetd/config.toml
sudo mkdir -p /etc/pam.d
sudo cp "$HOME/.dotfiles/system_config/pam.d/greetd" /etc/pam.d/greetd

# core and CLI packages
core_pkgs=(
  zsh zoxide fzf ripgrep fd dust duf btop tmux pacman-contrib reflector rsync sbctl nss-mdns wireless-regdb
  unzip wget tree tldr fastfetch git-delta github-cli udiskie tailscale ttf-jetbrains-mono-nerd openssh rclone
  rustup typst uv python jdk21-openjdk gcc clang cmake ninja nodejs-lts-jod neovim imagemagick doxygen lazygit
  arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-gdb arm-none-eabi-newlib openocd dtc noto-fonts npm
)
sudo pacman -S --needed --noconfirm "${core_pkgs[@]}"

# set zsh as default shell
chsh -s "$(which zsh)"

# AUR helper (yay)
if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
fi

echo "reminder: copy your ssh and gpg private keys from your secure backup into ~/.ssh and ~/.gnupg"
read -r -p "press enter proceed to wayland setup"

# stage: display server
wayland=(
  xorg-xwayland xwayland-satellite polkit-gnome gnome-keyring
  qt5-wayland qt6-wayland qt5ct qt6ct system-config-printer
  wl-clipboard cliphist ydotool brightnessctl
  mesa-utils vulkan-intel intel-media-driver intel-ucode
  pamixer pavucontrol playerctl ghostty wezterm yazi
  greetd greetd-tuigreet matugen dms-shell-niri
)

sudo pacman -S --needed --noconfirm "${wayland[@]}"

wayland_aur=(oh-my-posh)
yay -S --needed --noconfirm "${wayland_aur[@]}"

# enable login manager
sudo systemctl enable --now paccache.timer
sudo systemctl enable --now tailscaled
sudo systemctl enable greetd

sudo tailscale up

read -r -p "press enter to proceed to apps"

# stage: apps
app_pkgs=(
  btrfs-assistant btrfsmaintenance xdg-desktop-portal-gtk xdg-desktop-portal-gnome
  nautilus evince zathura zathura-pdf-mupdf imv mpv gnome-disk-utility
  firefox keepassxc libreoffice-fresh qbittorrent bitwarden kicad
)
sudo pacman -S --needed --noconfirm "${app_pkgs[@]}"

apps_aur=(
  freetube pear-desktop parsec-bin prospect-mail zoom
  ttf-ms-fonts consolas-font cnijfilter2 localsend-bin
  vivado stm32cubeide stm32cubemx stm32cubeprog
)
yay -S --needed --noconfirm "${apps_aur[@]}"

# init rust
rustup default stable

# enable user access to /dev/ttyACM0 which is the serial port where boards output to serial(UART) data
sudo usermod -aG uucp,dialout "$USER"
