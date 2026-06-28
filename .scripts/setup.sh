#!/bin/bash
set -e

# ==========================================
# STAGE: SECURE USB KEYS
# ==========================================

# create XDG dirs
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share"

# create secure ssh and gpg dirs
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

echo "available block devices:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS | grep -v "loop"

read -p $'\nenter the secure USB partition (default: sda1): ' usb_dev
usb_dev=${usb_dev:-sda1}

if [ -b "/dev/$usb_dev" ]; then
  # open LUKS container
  sudo cryptsetup open "/dev/$usb_dev" secure_usb
  # mount the decrypted mapping
  sudo mkdir -p /mnt/secure_usb
  sudo mount /dev/mapper/secure_usb /mnt/secure_usb

  # copy SSH keys and set permissions
  cp /mnt/secure_usb/crypt/ssh/id_ed25519 "$HOME/.ssh/id_ed25519"
  cp /mnt/secure_usb/crypt/ssh/id_ed25519.pub "$HOME/.ssh/id_ed25519.pub"
  chmod 600 "$HOME/.ssh/id_ed25519"
  chmod 644 "$HOME/.ssh/id_ed25519.pub"
  # import GPG keys
  gpg --import /mnt/secure_usb/crypt/gpg/public_identity.gpg
  gpg --import /mnt/secure_usb/crypt/gpg/private_identity.gpg
  gpg --import-ownertrust /mnt/secure_usb/crypt/gpg/trust_database.txt

  # unmount and lock
  sudo umount /mnt/secure_usb
  sudo cryptsetup close secure_usb
else
  echo "warning: /dev/$usb_dev not found, skipping key extraction"
  echo "manually import your SSH and GPG keys later"
fi

# edit pacman.conf
sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
# copy pacman hooks
sudo mkdir -p /etc/pacman.d/hooks
sudo cp "$HOME/.dotfiles/.system_config/pacman-hooks/50-uki-backup.hook" /etc/pacman.d/hooks/

# copy system configs
sudo mkdir -p /etc/greetd
sudo cp "$HOME/.dotfiles/.system_config/greetd/config.toml" /etc/greetd/config.toml
sudo mkdir -p /etc/pam.d
sudo cp "$HOME/.dotfiles/.system_config/pam.d/greetd" /etc/pam.d/greetd

# ==========================================
# STAGE: DOTFILES SETUP
# ==========================================

# setup dot files
if [ -d "$HOME/.dotfiles" ]; then
  cd "$HOME/.dotfiles"
  stow . --adopt
else
  echo "error: dotfiles dir not found, exiting"
  exit 1
fi

# archinstall created the config, so create snapshot
sudo snapper -c root create -c timeline --description "base: pre setup.sh"

# ==========================================
# STAGE: PACKAGE INSTALLATION
# ==========================================

# stage: core, cli and dev packages
core=(
  zsh openssh pacman-contrib reflector rsync sbctl nss-mdns wireless-regdb udiskie tailscale
  ttf-jetbrains-mono-nerd noto-fonts neovim unzip wget tree tldr git-delta
  zoxide fzf ripgrep fd dust duf btop tmux fastfetch imagemagick rclone
  github-cli lazygit rustup python jdk21-openjdk gcc clang cmake ninja nodejs-lts-jod npm uv typst doxygen
)
embedded=(openocd dtc arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-gdb arm-none-eabi-newlib)

sudo pacman -S --needed --noconfirm "${core[@]}"

read -p "install ARM toolchain: openocd, dtc, arm-none-eabi-gcc, arm-none-eabi-binutils, arm-none-eabi-gdb, arm-none-eabi-newlib? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then sudo pacman -S --needed --noconfirm "${embedded[@]}"; fi

# set zsh as default shell
chsh -s "$(which zsh)"

# AUR helper (yay)
if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay && makepkg -si
  cd ~
fi

# TODO: make sure to copy yay lua config from dot files

read -r -p "press enter proceed to wayland setup"

# stage: display server packages
wayland=(
  mesa-utils vulkan-intel intel-media-driver intel-ucode
  greetd greetd-tuigreet dms-shell-niri matugen
  xorg-xwayland xwayland-satellite polkit-gnome gnome-keyring
  wl-clipboard cliphist ydotool brightnessctl pamixer pavucontrol playerctl
  qt5-wayland qt6-wayland qt5ct qt6ct ghostty wezterm yazi
)

sudo pacman -S --needed --noconfirm "${wayland[@]}"

wayland_aur=(oh-my-posh)
yay -S --needed --noconfirm "${wayland_aur[@]}"

# enable login manager
sudo systemctl enable --now paccache.timer
sudo systemctl enable greetd

sudo systemctl enable --now tailscaled
sudo tailscale up

read -r -p "press enter to proceed to apps"

# stage: apps
app=(
  xdg-desktop-portal-gnome btrfs-assistant btrfsmaintenance gnome-disk-utility nautilus
  evince zathura zathura-pdf-mupdf imv mpv system-config-printer
  firefox keepassxc bitwarden libreoffice-fresh qbittorrent kicad
)
sudo pacman -S --needed --noconfirm "${app[@]}"

apps_aur=(
  freetube pear-desktop prospect-mail zoom cnijfilter2 localsend-bin
  # ttf-ms-fonts consolas-font parsec-bin
)
apps_aur_opt=(vivado stm32cubeide stm32cubemx stm32cubeprog)

yay -S --needed --noconfirm "${apps_aur[@]}"

read -p "install apps: vivado, stm32cubeide, stm32cubemx, stm32cubeprog? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  yay -S --needed --noconfirm "${apps_aur_opt[@]}"
fi

# init rust
rustup default stable

# enable user access to /dev/ttyACM0 which is the serial port where boards output to serial(UART) data
sudo usermod -aG uucp,dialout "$USER"
