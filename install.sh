#!/bin/bash
set -euxo pipefail

# Directories
ROOT_DIR="${HOME}/.local"
SRC_DIR="${HOME}/git"
NVIM_DIR="${SRC_DIR}/neovim"

# Install required dependencies
sudo apt-get update
sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential stow

# Clone Neovim stable (shallow clone for speed)
if [ ! -d "${NVIM_DIR}" ]; then
    mkdir -p "${SRC_DIR}"
    git clone --branch stable --depth 1 https://github.com/neovim/neovim.git "${NVIM_DIR}"
fi

# Build and install Neovim system-wide
pushd "${NVIM_DIR}"
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
popd

# Append dotfiles auto-setup to .zshrc if not already present
if ! grep -q "## dotfiles auto-setup" "${HOME}/.zshrc"; then
  cat << 'EOF' >> "${HOME}/.zshrc"

## dotfiles auto-setup: clone heliomeiralins/dotfiles and stow nvim if not present
if [ ! -d "${HOME}/dotfiles" ]; then
  echo "[dotfiles] Cloning heliomeiralins/dotfiles..."
  git clone --depth 1 https://github.com/heliomeiralins/dotfiles.git "${HOME}/dotfiles"
  echo "[dotfiles] Running stow for nvim..."
  cd "${HOME}/dotfiles" && stow nvim
fi
EOF
fi

