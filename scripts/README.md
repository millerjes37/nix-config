# Nix Configuration Scripts

This directory contains scripts for managing your Nix configuration.

## Directory Structure

- `scripts/`: Main scripts directory
  - `utils/`: Utility functions and shared code
    - `common.sh`: Common utility functions used by all scripts
    - `check-tools.sh`: Script to check if required tools are installed
  - `window-manager/`: Window manager related scripts
    - `setup.sh`: Setup script for window managers (Yabai and SKHD)
    - `fix.sh`: Fix script for window manager issues
  - `post-rebuild-hooks.sh`: Hooks that run after a Nix rebuild
  - `rebuild.sh`: Main script to rebuild Nix configuration

## Core Scripts

### Rebuild Script

The main script for rebuilding your Nix configuration:

```bash
./scripts/rebuild.sh
```

This script will:
1. Check for git changes and optionally commit them
2. Rebuild your Nix configuration with Home Manager
3. Run any post-rebuild hooks
4. Optionally push changes to your git remote

### Window Manager Scripts

The window manager scripts have been consolidated into a more organized structure:

```bash
# Set up window managers
./scripts/window-manager/setup.sh

# Fix window manager issues
./scripts/window-manager/fix.sh

# Show help for window manager setup
./scripts/window-manager/setup.sh --help

# Show help for window manager fixes
./scripts/window-manager/fix.sh --help
```

### Utility Scripts

Various utility scripts to help with your Nix setup:

```bash
# Check if required tools are installed
./scripts/utils/check-tools.sh
```

## Post-Rebuild Hooks

This script runs automatically after a rebuild and performs additional setup tasks like:

- Setting up window managers if they're managed outside of Nix/Home Manager

## Prerequisites

These scripts assume you have:

1. Nix installed
2. Home Manager installed
3. A basic understanding of Nix and Home Manager

## Usage Tips

1. Always run scripts from the root of your nix-config directory
2. Check the help output for each script to see available options
3. The rebuild script is the main entry point for most operations