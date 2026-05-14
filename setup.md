# arch linux setup
## system architecture
- os: arch linux
- filesystem: btrfs with snapper 
- bootloader: grub
- display Server: wayland
- compositor: niri
- greeter (login): greetd with tuigreet
- shell and status bar: DankMaterialShell (dms)
- terminal emulator: ghostty / wezTerm
- audio subsystem: pipeWire and wirePlumber

## packages
### system core and boot
The foundation of the operating system, kernel management, and filesystem.
-  kernels: linux,  linux-lts 
-  firmware and microcode: linux-firmware, intel-ucode
-  base utilities: base, base-devel, zram-generator
-  boot management: grub, efibootmgr
-  filesystem: btrfs-progs, dosfstools, mtools, udiskie, fuse-overlayfs
-  system recovery (snapper): snapper, btrfs-assistant, btrfsmaintenance, snap-pac, snap-pac-grub

### graphics, display and wayland
- drivers: mesa-utils, vulkan-intel
- compositor and shell: niri, dms-shell, dms-shell-niri
- login manager: greetd, greetd-tuigreet
- x11 compatibility: xwayland-satellite
- desktop portals and auth: xdg-desktop-portal-gnome, polkit-gnome, gnome-keyring, xdg-user-dirs-gtk
- toolkit integration: qt5-wayland, qt6-wayland, qt5ct, qt6ct
- wayland utilities: wl-clipboard, cliphist , ydotool, brightnessctl
- theming: matugen
 
### networking and sound
- networking: networkmanager, nss-mdns, wireless-regdb
- security and vpn: tailscale, ufw (uncomplicated firewall), openssh, nmap
- cloud and file sharing: rclone, localsend-bin
- audio engine: pipewire-pulse (Pulls in PipeWire base), pamixer, pulsemixer, pavucontrol
- media keys: playerctl

### fonts and localization
- monospace coding: ttf-jetbrains-mono, ttf-jetbrains-mono-nerd, consolas-font
- system: noto-fonts, ttf-ms-fonts, ttf-linux-libertine
- symbols: noto-fonts-emoji, ttf-nerd-fonts-symbols
- OCR and language: tesseract-data-heb
 
### terminal, shell and CLI tools
- terminals: ghostty, wezterm
- shell and prompt: zsh, oh-my-posh
- multiplexers: tmux
- editors: neovim, nano
- file management: yazi
- modern CLI Utilities: fzf, zoxide, ripgrep, fd, jq, bat
- system Monitoring: btop, fastfetch, dust, duf, gdu, lsof, tree
- git and version control: git, lazygit, github-cli, git-cliff, git-delta, git-filter-repo
- arch specific: yay, pacman-contrib, pkgfile, reflector, stow

### desktop apps
- web browsers: firefox
- file management: nautilus, gvfs, gvfs-mtp (Android mounting)
- document readers: evince, zathura, zathura-pdf-mupdf
- media and image: imv, gimp, obs-studio, mpv, freetube
- productivity: libreoffice-fresh, typst, zoom
- security: keepassxc, bitwarden, libxcrypt-compat
- utilities: qbittorrent, pear-desktop, prospect-mail, parsec-bin
- printing: cups, system-config-printer, cnijfilter2 (canon drivers)
 
### embedded dev
- arm toolchain: arm-none-eabi-gcc, arm-none-eabi-binutils, arm-none-eabi-gdb, arm-none-eabi-newlib
- stm32 Ecosystem: stm32cubeide, stm32cubemx, stm32cubeprog, stlink-server
- hardware debug: openocd, dfu-util, fxload, digilent.adept.runtime, digilent.adept.utilities
- FPGA and PCB: vivado, kicad
- 3D CAD: freecad
- serial communication: tio
- compilers and build systems: cmake, ninja, doxygen, bear, rust, cgal
- languages and environments: nodejs-lts-jod, npm, ruby, jdk21-openjdk
- python: python-pip, python-requests, python-jupyter-client, python-ipykernel, python-h5py, python-setuptools
- device tools: rpi-imager, dtc (device tree compiler)
