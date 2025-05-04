#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Path to the nix-config directory
NIX_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${BLUE}====== SETTING UP SYMLINKS FOR NIX CONFIG ======${NC}"

# Create bin directory if it doesn't exist
if [ ! -d "$HOME/bin" ]; then
  echo -e "${YELLOW}Creating $HOME/bin directory...${NC}"
  mkdir -p "$HOME/bin"
fi

# Add bin directory to PATH if not already there
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  echo -e "${YELLOW}Adding $HOME/bin to PATH in shell profile...${NC}"
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zprofile"
fi

# Create symlink for nixrebuild
echo -e "${YELLOW}Creating symlink for nixrebuild...${NC}"
ln -sf "$NIX_CONFIG_DIR/scripts/rebuild.sh" "$HOME/bin/nixrebuild"
chmod +x "$HOME/bin/nixrebuild"

# Create symlink for window manager installer
echo -e "${YELLOW}Creating symlink for window manager installer...${NC}"
ln -sf "$NIX_CONFIG_DIR/scripts/install-window-managers.sh" "$HOME/bin/install-window-managers"
chmod +x "$HOME/bin/install-window-managers"

# Create symlink for SKHD fixer
echo -e "${YELLOW}Creating symlink for SKHD fix utility...${NC}"
ln -sf "$NIX_CONFIG_DIR/scripts/fix-skhd.sh" "$HOME/bin/fix-skhd"
chmod +x "$HOME/bin/fix-skhd"

echo -e "${GREEN}Symlinks created successfully!${NC}"
echo -e "${YELLOW}You can now run 'nixrebuild' from anywhere.${NC}"
echo -e "${BLUE}====== DONE ======${NC}"