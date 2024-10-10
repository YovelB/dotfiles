# My dotfiles

This directory contains the dotfiles for my system

## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Requirements

Ensure you have the following installed on your system

### Git

```
sudo dnf install git
```

### Stow

```
sudo dnf install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone https://github.com/YovelB/dotfiles
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```

## Usage

After installation, you can manage your dotfiles by editing the files in this repository. Any changes made here will be reflected in your system configurations.

### Dependencies
#### 1. Tmux plugins
Clone TPM (Tmux plugin manager)
```
$ git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
Then run TPM installation command (prefix + I) to install the other plugins

Measure current start time with:
```
time zsh -i -c exit
output:
zsh -i -c exit  0.07s user 0.06s system 100% cpu 0.131 total
```
For detailed measurement:
```
# Uncomment zmodload zsh/zprof at top and zprof at bottom
zsh -i -c exit
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss what you would like to change.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
