# Nix Configuration

This repository contains my personal Nix configuration for both macOS and Linux systems using [Home Manager](https://github.com/nix-community/home-manager).

## Components

- **Alacritty**: Modern terminal emulator with GPU acceleration
- **Zsh**: Shell configuration with useful aliases and settings
- **Yabai**: Tiling window manager for macOS
- **Skhd**: Simple hotkey daemon for macOS
- **Emacs**: Doom Emacs configuration with programming language support
  - Includes support for Rust, Python, Go
  - Email integration via mu4e
  - Git integration with magit
  - LSP support for all major languages
- **Neovim**: Feature-rich editor configuration via NixVim
  - Comprehensive LSP setup for multiple languages
  - Tokyo Night theme with beautiful UI
  - Git integration (Neogit, Gitsigns, Diffview)
  - Harpoon for quick file navigation
  - Terminal integration with Toggleterm
  - Tree-sitter for better syntax highlighting
  - See [neovim.md](modules/neovim.md) for details

## Usage

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/nix-config.git
cd nix-config

# Install Home Manager if needed
nix profile install nixpkgs#home-manager

# Initial build
home-manager switch -b backup --flake .#jacksonmiller
```

### Rebuild Script

A rebuild script is provided for easy configuration updates. After installing the configuration for the first time, set up symlinks to make the commands available system-wide:

```bash
# Run once after initial setup
~/nix-config/scripts/setup-symlinks.sh
```

Then you can run the rebuild command from anywhere:

```bash
# From any directory
nixrebuild
```

This will:
1. Show a diff of your changes
2. Offer to commit the changes with an auto-generated message
3. Rebuild your configuration
4. Run post-rebuild hooks (including window manager setup)
5. Offer to push changes to the remote repository

### Cross-Platform Support

The configuration is designed to work on both macOS and Linux with minimal adjustments.

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

3. Set up email (if using):
   ```bash
   # Create mail directory
   mkdir -p ~/.mail/jackson-civitas
   
   # Set up password in keychain
   security add-generic-password -a jackson@civitas.ltd -s mbsync-gmail-jackson-civitas -w
   
   # Initial sync
   mbsync -a
   
   # Initialize mu
   mu init --maildir=~/.mail --my-address=jackson@civitas.ltd
   mu index
   ```

## Structure

- `flake.nix`: Entry point for nix-flake
- `home.nix`: Main Home Manager configuration
- `modules/`: Directory containing module-specific configurations
  - `alacritty.nix`: Terminal configuration
  - `emacs.nix`: Doom Emacs configuration
  - `skhd.nix`: Keyboard shortcuts definition (used as reference)
  - `yabai.nix`: Window manager configuration (used as reference)
  - `zsh.nix`: Shell configuration
- `scripts/`: Helper scripts
  - `rebuild.sh`: Script to update and rebuild configuration
  - `post-rebuild-hooks.sh`: Post-rebuild automation
  - `install-window-managers.sh`: Window manager setup script
  - `yabairc`, `skhdrc`: Window manager configurations
  - `skhd-cheatsheet.md`: Keyboard shortcut reference
- `README-WINDOW-MANAGERS.md`: Detailed window manager setup guide
- `WINDOW-MANAGER-INTEGRATION.md`: Technical details about the integration