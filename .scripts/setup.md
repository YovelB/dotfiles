# Arch Linux Setup

## ArchInstall script 
-  [pre installation](https://wiki.archlinux.org/title/Installation_guide#Pre-installation) acquire an installation image (`iso`) and the respective pgp signature for USB drive using `torrent` and verify using `gpg`
- prepare installation medium to create a USB bootable arch installation using gnome disk utility:
  - right click the `iso` file to open with `Disk Image Writer`
  - specify the USB drive as destination and start restoring
- boot into into arch live and connect to WiFi via [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl):
  - `device list` - list all WiFi devices
  - `station wlan0 scan` - scan for networks
  - `station wlan0 get-networks` - list networks
  - `station --passphrase passphrase wlan0 connect <SSID>` - connect to network with password
- **Archinstall with config**:
  e locales: keyboard layout: us, language: en_IL, encoding: UTF-8, console font: default8x16
  - mirrors: regions: Israel, Germany, France, Nett the files you /.dotfiles/.scripts/rclone-sync.sh enable rclone sync

  herlands repositories: multilib
  - disk Configuration: best effort partition layout, file system: btrfs with default sub volumes structure with CoW enabled:
    - 1 GiB of fat32 for /boot and the rest of btrfs, NO LVM.
    - mount points: /, /home, /var/log, /var/cache/pacman/pkg
    - disk encryption: LUKS passphrase, iteration time: 2000 ms
    - btrfs snapshots: snapper
  - swap: zram with zstd compression
  - bootloader: systemd-boot + unified kernel images (UKI)
  - kernels: linux, linux-lts
  - authentication: root: locked account (empty password), user: yovel, no U2F (no Yubikey)
  - profile: desktop: niri - DankMaterialShell, graphics driver: intel (open source), greeter: dms-greeter
    - installed packages: 
    alacritty, cava, cups-pk-helper, dms-shell-niri, kimageformats, matugen, network-manager-applet, niri, polkit, smartmontools, sof-firmware, tuned-ppd, wireplumber, xdg-desktop-portal-gnome, xdg-utils, xorg-xwayland
    alacritty, cava, cups-pk-helper, dms-shell-niri, kimageformats, matugen, niri, polkit, tuned-ppd, xdg-desktop-portal-gnome, xorg-xwayland
  - applications: bluetooth, audio: pipewire, print: cups, firewall: ufw, fonts: noto-fonts, noto-fonts-emoji, ttf-liberation
  - network configuration: use network manager (default backend)

note: if using systemd-boot + UKI, there is a need for pacman hook to backup the UKI before kernel updates

## setup.sh script
### before script
```bash
pacman -Syu
pacman -S pacman-contrib base-devel snap-pac git stow xdg-user-dirs-gtk openssh
git clone https://codeberg.org/YovelB/dotfiles.git ~/.dotfiles
cd ~/.dotfiles/.scripts
chmod +x setup.sh
./setup.sh
```

### after script:
- `secure_boot.md` to enable secure boot and TPM2 LUKS binding
- rclone setup:
```bash
# with two drives gdrive - google drive, pdrive - proton drive
rclone config
# make sure your ~/.dotfiles/.scripts/rclone-sync.sh script is configured to enable rclone sync
systemctl --user enable --now rclone-sync.timer
```
- tailscale setup:
```bash
sudo systemctl enable --now tailscaled
sudo tailscale up
```

## system architecture
- os: arch linux
- file system: btrfs with snapper 
- bootloader: systemd-boot + UKI
- display server: wayland
- compositor: niri
- greeter (login): greetd with dms-greeter
- shell and status bar: DankMaterialShell (dms)
- terminal emulator: ghostty, wezterm, alacritty
- audio subsystem: pipeWire
- dotfiles: gnu stow

## packages
### system core and boot
- base utilities: base, base-devel, linux, linux-lts, linux-firmware, intel-ucode, zram-generator
- boot management: systemd-boot, efibootmgr, sbctl
- filesystem: btrfs-progs, udiskie
- system recovery: snapper, btrfs-assistant, btrfsmaintenance, snap-pac

### graphics, display and wayland
- drivers: mesa-utils, vulkan-intel, intel-media-driver
- compositor and shell: niri, dms-shell, dms-shell-niri
- login manager: greetd, greetd-tuigreet
- x11 compatibility: xorg-xwayland, xwayland-satellite
- desktop portals and auth: xdg-desktop-portal-gnome, polkit-gnome, gnome-keyring, xdg-user-dirs-gtk
- toolkit integration: qt5-wayland, qt6-wayland, qt5ct, qt6ct
- wayland utilities: wl-clipboard, cliphist, ydotool, brightnessctl
- theming: matugen
 
### networking and sound
- networking: networkmanager, nss-mdns, wireless-regdb, bluez, bluez-utils
- security and vpn: tailscale, ufw, openssh
- cloud and file sharing: rclone, localsend-bin
- audio engine: pipewire-pulse, pamixer, pulsemixer, pavucontrol, playerctl

### fonts
- monospace coding: ttf-jetbrains-mono-nerd
- system: noto-fonts, noto-fonts-emoji, ttf-liberation
<!-- - OCR and language: tesseract-data-heb -->
 
### terminal, shell and CLI tools
- terminals: ghostty, wezterm
- shell and prompt: zsh, oh-my-posh
- multiplexers: tmux
- editors: neovim
- file management: yazi
- modern CLI Utilities: fzf, zoxide, ripgrep, fd, dust, duf, btop, fastfetch, tree
- git and version control: git, lazygit, github-cli, *git-cliff*, git-delta, *git-filter-repo*
- arch specific: paru, pacman-contrib, pkgfile, reflector, stow
- core utilities: unzip, wget, tldr, imagemagick

### desktop apps
- web browsers: firefox
- file management: nautilus, gvfs, gvfs-mtp (android mounting)
- document readers: evince, zathura, zathura-pdf-mupdf
- media and image: imv, mpv, freetube
- productivity: libreoffice-fresh, typst, zoom
- security: keepassxc, bitwarden
- utilities: qbittorrent, pear-desktop, prospect-mail, parsec-bin
- printing: cups, system-config-printer, cnijfilter2 (canon drivers)
 
### embedded dev
- arm toolchain: arm-none-eabi-gcc, arm-none-eabi-binutils, arm-none-eabi-gdb, arm-none-eabi-newlib, openocd
- stm32 Ecosystem: stm32cubeide, stm32cubemx, stm32cubeprog, stlink-server
<!-- - hardware debug: dfu-util, fxload, digilent.adept.runtime, digilent.adept.utilities -->
- FPGA and PCB: vivado, kicad
- compilers and build systems: gcc, clangd, cmake, ninja, doxygen, rustup
- languages and environments: uv, nodejs-lts-jod, npm
- device tools: dtc (device tree compiler)

## arch wiki references ([arch wiki](https://wiki.archlinux.org))
- [arch installer](https://wiki.archlinux.org/title/Archinstall),
- [system maintenance](https://wiki.archlinux.org/title/System_maintenance), 
- [wayland](https://wiki.archlinux.org/title/Wayland),
- [greetd](https://wiki.archlinux.org/title/Greetd),
- [btrfs](https://wiki.archlinux.org/title/Btrfs), [snapper](https://wiki.archlinux.org/title/Snapper),
- [pacman tips/tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
