#!/bin/bash
set -e

# ==========================================
# STAGE: SECURE USB KEYS
# ==========================================

# create secure ssh and gpg dirs
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

echo "available block devices:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS | grep -v "loop"

read -r -p $'\nenter secure USB partition (e.g. sda1, or press Enter/type "s" to skip): ' usb_dev

if [[ -n "$usb_dev" && "$usb_dev" != "s" && "$usb_dev" != "skip" ]]; then
  if [ -b "/dev/$usb_dev" ]; then
    echo "opening LUKS, enter passphrase"
    if sudo cryptsetup open "/dev/$usb_dev" secure_usb; then
      # mount the decrypted mapping
      sudo mkdir -p /mnt/secure_usb
      sudo mount /dev/mapper/secure_usb /mnt/secure_usb

      # copy SSH keys and set permissions
      cp /mnt/secure_usb/crypt/ssh/id_ed25519 "$HOME/.ssh/id_ed25519"
      cp /mnt/secure_usb/crypt/ssh/id_ed25519.pub "$HOME/.ssh/id_ed25519.pub"
      chmod 600 "$HOME/.ssh/id_ed25519"
      chmod 644 "$HOME/.ssh/id_ed25519.pub"
      # import GPG keys
      echo "import GPG, enter passphrase"
      gpg --import /mnt/secure_usb/crypt/gpg/public_identity.gpg || echo "failed to import public GPG key."
      gpg --import /mnt/secure_usb/crypt/gpg/private_identity.gpg || echo "failed to import private GPG key."
      gpg --import-ownertrust /mnt/secure_usb/crypt/gpg/trust_database.txt || true

      # unmount and lock
      sudo umount /mnt/secure_usb
      sudo cryptsetup close secure_usb
    else
      echo "warning: failed to open LUKS, wrong passphrase"
    fi
  else
    echo "warning: /dev/$usb_dev not found, skipping key extraction"
    echo "manually import your SSH and GPG keys later"
  fi
else
  echo "skipping key extraction."
fi

# edit pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
fi
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

# copy pacman hooks
sudo mkdir -p /etc/pacman.d/hooks
sudo cp "$HOME/.dotfiles/.system_config/pacman-hooks/50-uki-backup.hook" /etc/pacman.d/hooks/

# copy system configs
# sudo mkdir -p /etc/greetd
# sudo cp "$HOME/.dotfiles/.system_config/greetd/config.toml" /etc/greetd/config.toml
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

# create snapshot
if command -v snapper &>/dev/null; then
  sudo snapper -c root create -c timeline --description "base: pre setup.sh"
else
  echo "warning: snapper is not installed yet. skipping pre-setup snapshot."
fi

# ==========================================
# STAGE: PACKAGE INSTALLATION
# ==========================================

# stage: core, cli and dev packages
core=(
  man-db zsh reflector rsync sbctl nss-mdns tpm2-tools wireless-regdb udiskie tailscale
  ttf-jetbrains-mono-nerd neovim tree-sitter-cli unzip tree tldr git-delta
  zoxide fzf ripgrep fd dust duf btop tmux fastfetch imagemagick rclone
  github-cli lazygit rustup clang cmake ninja npm uv typst doxygen

  wl-clipboard cliphist keyd ydotool brightnessctl pavucontrol playerctl pamixer rtkit
  qt5-wayland qt6-wayland qt5ct qt6ct ghostty wezterm yazi
  # smartmontools tpm2-tools xdg-utils network-manager-applet
  # pipewire wireplumber sof-firmware
  # xwayland-satellite polkit-gnome gnome-keyring jdk21-openjdk
)
embedded=(openocd dtc arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-gdb arm-none-eabi-newlib)

sudo pacman -S --needed --noconfirm "${core[@]}"

read -p "install ARM toolchain: openocd, dtc, arm-none-eabi-gcc, arm-none-eabi-binutils, arm-none-eabi-gdb, arm-none-eabi-newlib? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then sudo pacman -S --needed --noconfirm "${embedded[@]}"; fi

# set zsh as default shell
chsh -s "$(which zsh)"

if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  echo "inside tmux press ctrl+space then shift+I to download plugins"
fi

# init rust
rustup default stable

# AUR helper (paru)
if ! command -v paru &>/dev/null; then
  cd /tmp
  rm -rf paru
  git clone https://aur.archlinux.org/paru.git
  cd paru && makepkg -si --noconfirm
  cd ~
fi

wayland_aur=(oh-my-posh)
paru -S --needed --noconfirm "${wayland_aur[@]}"

# enable paccache timer
sudo systemctl enable --now paccache.timer

read -r -p "press enter to proceed to apps"

# stage: apps
app=(
  btrfs-assistant btrfsmaintenance gnome-disk-utility nautilus
  evince zathura zathura-pdf-mupdf imv mpv
  firefox keepassxc bitwarden libreoffice-fresh qbittorrent kicad
)
sudo pacman -S --needed --noconfirm "${app[@]}"

apps_aur=(
  freetube pear-desktop localsend-bin ttf-ms-fonts
  # parsec-bin prospect-mail zoom cnijfilter2
)
apps_aur_opt=(vivado stm32cubeide stm32cubemx stm32cubeprog)

paru -S --needed --noconfirm "${apps_aur[@]}"

read -p "install apps: vivado, stm32cubeide, stm32cubemx, stm32cubeprog? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  paru -S --needed --noconfirm "${apps_aur_opt[@]}"
fi

# copy keyd config
sudo cp "$HOME/.dotfiles/.system_config/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd
sudo keyd reload

# copy udev rules for ydotool input manipulation
sudo cp "$HOME/.dotfiles/.system_config/rules.d/80-uinput.rules" /etc/udev/rules.d/
# reload udev
sudo udevadm control --reload-rules && sudo udevadm trigger
# enable user access to /dev/ttyUSB0 by adding to groups uucp and dialout, input is for ytodtool to hardware input
#NOTE: need to log out and in for it to take effect
sudo usermod -aG input,uucp,dialout "$USER"
