# Cross-Platform Nix Configuration

This repository contains a Nix configuration for home-manager that works on both macOS and Linux.

## Project Goals

The primary goal of this Nix configuration is to provide a consistent, reproducible, and easily manageable development environment across both macOS and Linux systems. It aims to:

-   **Simplify Setup**: Automate the installation and configuration of development tools, shell environments, and window managers.
-   **Ensure Consistency**: Maintain a synchronized environment across different machines and operating systems.
-   **Promote Modularity**: Allow for easy addition and customization of applications and system settings through a modular structure.
-   **Leverage Nix Flakes**: Utilize the power of Nix flakes for better dependency management and reproducibility.
-   **Be Extensible**: Provide a clear framework for users to add their own tools and configurations.

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
│   ├── common/             # Shared core environment modules for both platforms
│   │   ├── default.nix     # Common module imports
│   │   ├── alacritty.nix   # Terminal configuration
│   │   ├── zsh.nix         # Shell configuration
│   │   └── emacs.nix       # Editor configuration
│   ├── darwin/             # macOS-specific core environment modules
│   │   ├── default.nix     # Main macOS module
│   │   ├── yabai.nix       # Window management
│   │   ├── skhd.nix        # Hotkey daemon
│   │   └── apps.nix        # macOS applications (deprecated, see applications/)
│   └── linux/              # Linux-specific core environment modules
│       ├── default.nix     # Main Linux module
│       ├── i3.nix          # Window management
│       ├── rofi.nix        # Application launcher
│       ├── gtk.nix         # GTK theming
│       └── linux-apps.nix  # Linux applications (deprecated, see applications/)
├── applications/           # User-specific applications and services
│   ├── common/             # Applications for both platforms
│   │   └── default.nix     # Imports for common applications
│   ├── darwin/             # macOS-specific applications
│   │   └── default.nix     # Imports for macOS-specific applications
│   └── linux/              # Linux-specific applications
│       └── default.nix     # Imports for Linux-specific applications
└── scripts/
    ├── rebuild.sh          # Cross-platform rebuild script
    └── ...
```
The `modules/` directory contains core environment configurations (shell, terminal, editors, window managers).
The `applications/` directory is intended for user-added applications and services, keeping them separate from the core environment setup.

## Adding New Applications as Modules

This configuration encourages adding new applications or services as self-contained modules. This approach enhances organization and makes it easier to manage and customize your setup.

### Philosophy

-   **Modularity**: Each application should ideally reside in its own `.nix` file, defining its package and any specific configurations.
-   **Separation of Concerns**:
    -   **Core Environment Modules (`modules/`)**: These define the fundamental parts of your environment (shell, terminal, window manager, core development tools like Git). Changes here are generally less frequent.
    -   **User Applications/Services (`applications/`)**: This is where you add most of your day-to-day applications, tools, or background services. This directory is designed for more frequent customization by the user.

### Adding a Common Application

Common applications are those you want to be available on both macOS and Linux.

1.  **Create the Application File**:
    Create a new `.nix` file in the `applications/common/` directory. For example, to add a hypothetical notes application called `simplenotes`, you would create `applications/common/simplenotes.nix`.

2.  **Define the Application**:
    In `applications/common/simplenotes.nix`, define the package and any configuration.
    ```nix
    # applications/common/simplenotes.nix
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.simplenotes # Assuming 'simplenotes' is available in nixpkgs
      ];

      # Optional: Add any configuration for simplenotes here
      # environment.variables = { SIMPLENOTES_CONFIG_DIR = "~/.config/simplenotes"; };
    }
    ```

3.  **Import the Module**:
    Open `applications/common/default.nix`. If this file doesn't exist, create it. This file serves as an importer for all common applications.
    Add your new application module to its `imports` list:
    ```nix
    # applications/common/default.nix
    { ... }:

    {
      imports = [
        ./simplenotes.nix
        # ./another-common-app.nix
      ];
    }
    ```
    Finally, ensure that `applications/common/default.nix` is imported into your main `home.nix` or a relevant common modules aggregator if you have one (e.g., `modules/common/default.nix` might be a good place if it imports user applications). For this setup, let's assume it's imported into `modules/common/default.nix`:

    ```nix
    # modules/common/default.nix
    { pkgs, ... }:

    {
      imports = [
        ./alacritty.nix
        ./zsh.nix
        ./emacs.nix
        ../../applications/common/default.nix # <-- Add this line
      ];

      # ... other common configurations
    }
    ```

### Adding a Platform-Specific Application

Platform-specific applications are those intended only for macOS or only for Linux.

1.  **Create the Application File**:
    Create a new `.nix` file in the appropriate platform-specific directory.
    -   For a macOS GUI app like `supernotes-gui`, create `applications/darwin/supernotes-gui.nix`.
    -   For a Linux utility like `ksysguard`, create `applications/linux/ksysguard.nix`.

2.  **Define the Application**:
    In the new file (e.g., `applications/darwin/supernotes-gui.nix`):
    ```nix
    # applications/darwin/supernotes-gui.nix
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.supernotes-gui # Assuming this package exists for darwin
      ];

      # Optional: macOS-specific settings
      # services.supernotes-agent = { enable = true; };
    }
    ```

3.  **Import the Module**:
    Open the `default.nix` file for that platform within the `applications` directory (e.g., `applications/darwin/default.nix` or `applications/linux/default.nix`). If these files don't exist, create them.
    Add your new application module to its `imports` list:

    ```nix
    # applications/darwin/default.nix
    { ... }:

    {
      imports = [
        ./supernotes-gui.nix
        # ./another-darwin-app.nix
      ];
    }
    ```
    Then, import this platform-specific application aggregator into the main platform module:

    For macOS, edit `modules/darwin/default.nix`:
    ```nix
    # modules/darwin/default.nix
    { pkgs, ... }:

    {
      imports = [
        ./yabai.nix
        ./skhd.nix
        # ./apps.nix # This can be removed or refactored if it only contained packages
        ../../applications/darwin/default.nix # <-- Add this line
      ];

      # ... other macOS configurations
    }
    ```
    For Linux, edit `modules/linux/default.nix`:
    ```nix
    # modules/linux/default.nix
    { pkgs, ... }:

    {
      imports = [
        ./i3.nix
        ./rofi.nix
        ./gtk.nix
        # ./linux-apps.nix # This can be removed or refactored
        ../../applications/linux/default.nix # <-- Add this line
      ];

      # ... other Linux configurations
    }
    ```

This modular approach keeps your application configurations tidy and makes it straightforward to see what's installed where.

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
   - Refer to the "Adding New Applications as Modules" section above.

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
- **Homebrew Integration**: Template for Homebrew bundle (Note: managing apps via Nix is preferred)

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