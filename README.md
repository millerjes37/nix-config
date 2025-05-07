# Cross-Platform Nix Configuration

This repository contains a Nix configuration for home-manager that works on both macOS and Linux.

## Overview

This configuration uses Nix flakes and home-manager to manage:

- Shell environment (zsh with powerlevel10k)
- Terminal emulator (Alacritty)
- Development tools (Neovim, Git, etc.)
- Window management:
  - macOS: yabai (tiling window manager) and skhd (hotkey daemon)
  - Linux: i3 (tiling window manager)

## Structure

The configuration is organized with a modular approach:

```
.
├── flake.nix               # Flake definition and outputs
├── home.nix                # Main home-manager configuration
├── configuration.nix       # Darwin system configuration (macOS only)
├── modules/
│   ├── common/             # Shared modules for both platforms
│   │   ├── default.nix     # Common module imports
│   │   ├── alacritty.nix   # Terminal configuration
│   │   ├── zsh.nix         # Shell configuration
│   │   └── emacs.nix       # Editor configuration
│   ├── darwin/             # macOS-specific modules
│   │   ├── default.nix     # Main macOS module
│   │   ├── yabai.nix       # Window management
│   │   ├── skhd.nix        # Hotkey daemon
│   │   └── apps.nix        # macOS applications
│   └── linux/              # Linux-specific modules
│       ├── default.nix     # Main Linux module
│       ├── i3.nix          # Window management
│       ├── rofi.nix        # Application launcher
│       ├── gtk.nix         # GTK theming
│       └── linux-apps.nix  # Linux applications
└── scripts/
    ├── rebuild.sh          # Cross-platform rebuild script
    └── ...
```

## Usage

### Initial Setup

1. Install Nix:
   ```bash
   # macOS
   sh <(curl -L https://nixos.org/nix/install)
   
   # Linux
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Enable flakes:
   ```bash
   mkdir -p ~/.config/nix
   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
   ```

3. Install home-manager (flakes method):
   ```bash
   nix shell nixpkgs#home-manager
   ```

4. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nix-config.git ~/nix-config
   cd ~/nix-config
   ```

5. Build the configuration:
   ```bash
   # On macOS
   ./scripts/rebuild.sh
   
   # On Linux
   ./scripts/rebuild.sh
   ```

### Customization

1. Platform Detection:
   - Use `pkgs.stdenv.isDarwin` and `pkgs.stdenv.isLinux` for platform-specific options

2. Adding Custom Packages:
   - Common packages: Add to `modules/common/default.nix`
   - macOS-specific: Add to `modules/darwin/default.nix` or `modules/darwin/apps.nix`
   - Linux-specific: Add to `modules/linux/default.nix` or `modules/linux/linux-apps.nix`

### Key Features

#### Window Management Integration

- **macOS (yabai + skhd)**:
  - Tiling window management with yabai
  - Keybindings for window/space operations with skhd
  - The option+t keybinding activates window grid snapping

- **Linux (i3)**:
  - Tiling window management with i3
  - Keybindings similar to macOS setup for consistency
  - The mod+t keybinding activates window grid snapping (similar to macOS)

#### Development Environment

- **Shell**: Zsh with powerlevel10k, syntax highlighting, and autosuggestions
- **Terminal**: Alacritty with cross-platform keyboard shortcuts
- **Editors**: 
  - Neovim configuration with LSP support
  - Emacs with Doom Emacs framework
- **CLI Tools**: A comprehensive set of modern CLI tools (bat, eza, fd, ripgrep, etc.)

## Components

### Common Components

- **Alacritty**: Modern terminal emulator with GPU acceleration
- **Zsh**: Shell configuration with useful aliases and settings
- **Neovim**: Feature-rich editor configuration via NixVim
- **Emacs**: Doom Emacs configuration with programming language support

### macOS-Specific Components

- **Yabai**: Tiling window manager for macOS
- **Skhd**: Simple hotkey daemon for macOS
- **Homebrew Integration**: Template for Homebrew bundle

### Linux-Specific Components

- **i3**: Tiling window manager for Linux
- **Rofi**: Application launcher
- **GTK Themes**: Consistent theming for GTK applications
- **XDG Desktop Integration**: Properly configured file associations

## Manual Steps

After the initial setup, you'll need to:

1. Set up Window Managers (on macOS):
   ```bash
   # Run the window manager setup script
   ~/nix-config/scripts/install-window-managers.sh
   
   # Grant necessary permissions:
   # System Settings -> Privacy & Security -> Accessibility
   # Add /run/current-system/sw/bin/yabai and /run/current-system/sw/bin/skhd
   ```
   See [README-WINDOW-MANAGERS.md](README-WINDOW-MANAGERS.md) for detailed instructions.

2. Install Doom Emacs manually:
   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
   ~/.emacs.d/bin/doom install --no-config --no-env --no-fonts
   ```

## Maintenance

### Updating

Update your configuration regularly:

```bash
cd ~/nix-config
git pull
./scripts/rebuild.sh --upgrade
```

### Troubleshooting

If you encounter issues:

1. Check syntax: `nix flake check`
2. Run with verbose output: `./scripts/rebuild.sh --verbose`
3. Skip git operations if needed: `./scripts/rebuild.sh --skip-git`