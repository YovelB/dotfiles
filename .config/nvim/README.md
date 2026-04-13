## Neovim Config

*[Neovim](https://neovim.io/)* >= 0.12.1 configuration using the new vim.pack.

### Requirments

* [**Node.js** and **npm**](https://nodejs.org/), [**Git**](https://git-scm.com/), [**Ripgrep**](https://github.com/BurntSushi/ripgrep)
* [**Python** and **pip**](https://www.python.org/), [**GCC**](https://gcc.gnu.org/) (or [**Clang**](https://clang.llvm.org/)) and [**Make**](https://www.gnu.org/software/make/), [**Typst**](https://typst.app/), 
* [**wl-clipboard**](https://github.com/bugaevc/wl-clipboard) or [**xclip**](https://github.com/astrand/xclip), [**Nerd Font**](https://www.nerdfonts.com/)

### Installtion

#### Arch Linux

```bash
sudo pacman -Syu
sudo pacman -S --needed neovim git ripgrep base-devel nodejs npm python python-pip unzip wget curl typst ttf-jetbrains-mono-nerd
```

install a clipboard provider (based on your display server)
```bash
sudo pacman -S wl-clipboard   # wayland or
sudo pacman -S xclip          # x11
```

#### Windows 11

**option A: using Scoop (recommended)**

Scoop handles path variables and localized installations very well.
```powershell
scoop install neovim git ripgrep nodejs python typst gcc
```

**option B: using Winget**

```powershell
Winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.lzz Node.js Python.Python Typst.Typst
```
*note: If using Winget, you may still need to install a C compiler like GCC manually via MSYS2 for `nvim-treesitter` to compile parsers.*

**setting up a Nerd Font on Windows:**
- download your preferred font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads).
- extract the `.zip` file.
- select all the extracted font files, right click, and choose **Install for all users**.
- open your terminal emulator settings and set the font face to the new one.
