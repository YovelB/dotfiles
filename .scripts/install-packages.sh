#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

install_list() {
  local file=$1

  if [[ ! -f "$file" ]]; then
    log_error "Package list not found: $file"
    return 1
  fi

  log_info "Installing from: $(basename "$file")"

  local packages=$(grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' ')

  if [[ -n "$packages" ]]; then
    if sudo pacman -S --needed --noconfirm $packages; then
      log_info "Successfully installed packages from $(basename "$file")"
    else
      log_error "Failed to install some packages from $(basename "$file")"
      return 1
    fi
  else
    log_warn "No packages found in $(basename "$file")"
  fi
}

# Parse arguments
INSTALL_OPTIONAL=false
if [[ "$1" == "--with-optional" ]] 2>/dev/null; then
  INSTALL_OPTIONAL=true
fi

log_info "Installing essential packages..."
sudo pacman -Syu --noconfirm

install_list "$PACKAGES_DIR/essential.txt"

if [[ "$INSTALL_OPTIONAL" == true ]]; then
  log_warn "Installing optional packages..."
  install_list "$PACKAGES_DIR/optional.txt"
fi

log_info "Done! Essential packages installed."
[[ "$INSTALL_OPTIONAL" == false ]] && log_info "Run with --with-optional to install optional packages"
