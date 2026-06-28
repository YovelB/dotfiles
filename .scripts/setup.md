# Arch Linux Setup

## ArchInstall script 
-  [pre installation](https://wiki.archlinux.org/title/Installation_guide#Pre-installation) acquire an installation image (`iso`) and the respective pgp signature for USB drive using `turrent` and verify using `gpg`
- prepare installation medium to create a USB bootable arch installation using gnome disk utility:
  - right click the `iso` file to open with `Disk Image Writer`
  - specify the USB drive as destination and start restoring
- boot into into arch live and connect to WiFi via [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl):
  - `device list` - list all WiFi devices
  - `station wlan0 scan` - scan for networks
  - `station wlan0 get-networks` - list networks
  - `station --passphrase passphrase wlan0 connect SSID` - connect to network with password
- launch arch install with current configuration:
  - Locales: keyboard layout: us, language: en_IL, encoding: UTF-8
  - Mirrors: regions: Israel, Germany, France, Netherlands repositories: multilib
  - Disk Configuration: best effort partition layout, file system: btrfs with default sub volumes structure with CoW enabled:
    - 1 GiB of fat32 for /boot and the rest of btrfs, NO LVM.
    - mount points: /, /home, /var/log, /var/cache/packman/pkg
    - btrfs snapshots: snapper
  - Swap: zram with zstd compression
  - Bootloader: systemd-boot + unified kernal images (UKI)
  - Kernels: linux, linux-lts
  - Authentication: root: locked account (empty password), user: yovel, no U2F (no Yubikey)
  - profile: minimal
  - applications: Bluetooth, audio: pipewire + wireplumber, print: cups, firewall: ufw
  - network configuration: use network manager (default backend)
  - additional packages: 
  - bash script (packages that need setup): greetd-tuigreet (greetd and tuigreetd)

note: if using systemd-boot + UKI, there is a need for pacman hook to backup the UKI before kernal updates

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
- rclone config:
```bash
# with two drives gdrive - google drive, protondrive - proton drive
rclone config
# enable rclone sync
systemctl --user enable --now rclone-sync.timer
```

## system architecture
- os: arch linux
- file system: btrfs with snapper 
- bootloader: systemd-boot + UKI
- display server: wayland
- compositor: niri
- greeter (login): greetd with tuigreet
- shell and status bar: DankMaterialShell (dms)
- terminal emulator: ghostty / wezterm
- audio subsystem: pipeWire and wireplumber
- dotfiles: gnu stow

## packages
### system core and boot
- base utilities: linux, linux-lts, linux-firmware, intel-ucode, base-devel, zram-generator
- boot management: systemd-boot, efibootmgr, sbctl
- base utilities: base, base-devel, zram-generator
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
- system: noto-fonts, consolas-font, ttf-ms-fonts, 
<!-- - symbols: noto-fonts-emoji, ttf-nerd-fonts-symbols,  ttf-linux-libertine, ttf-jetbrains-mono -->
<!-- - OCR and language: tesseract-data-heb -->
 
### terminal, shell and CLI tools
- terminals: ghostty, wezterm
- shell and prompt: zsh, oh-my-posh
- multiplexers: tmux
- editors: neovim
- file management: yazi
- modern CLI Utilities: fzf, zoxide, ripgrep, fd, dust, duf, btop, fastfetch, tree
- git and version control: git, lazygit, github-cli, *git-cliff*, git-delta, *git-filter-repo*
- arch specific: yay, pacman-contrib, *pkgfile*, reflector, stow
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
