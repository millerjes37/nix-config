# Nix Config Restructure Plan

## New Directory Structure

```
nix-config/
├── applications/                     # Individual application modules
│   ├── common/                       # Cross-platform applications
│   │   ├── default.nix              # Imports all common apps
│   │   ├── editors/
│   │   │   ├── default.nix
│   │   │   ├── neovim.nix
│   │   │   ├── nixvim.nix
│   │   │   ├── helix.nix
│   │   │   └── emacs.nix
│   │   ├── development/
│   │   │   ├── default.nix
│   │   │   ├── git.nix
│   │   │   ├── languages.nix
│   │   │   ├── containers.nix
│   │   │   └── databases.nix
│   │   ├── media/
│   │   │   ├── default.nix
│   │   │   ├── gimp.nix
│   │   │   ├── audio-tools.nix
│   │   │   ├── video-tools.nix
│   │   │   └── workflows.nix
│   │   ├── terminal/
│   │   │   ├── default.nix
│   │   │   ├── alacritty.nix
│   │   │   ├── zsh.nix
│   │   │   ├── starship.nix
│   │   │   └── multiplexers.nix
│   │   ├── utilities/
│   │   │   ├── default.nix
│   │   │   ├── cli-tools.nix
│   │   │   ├── file-managers.nix
│   │   │   ├── system-monitoring.nix
│   │   │   ├── network-tools.nix
│   │   │   └── compression.nix
│   │   └── security/
│   │       ├── default.nix
│   │       ├── keepassxc.nix
│   │       ├── encryption.nix
│   │       └── password-managers.nix
│   ├── darwin/                       # macOS-specific applications
│   │   ├── default.nix
│   │   ├── homebrew.nix
│   │   ├── mas-apps.nix
│   │   ├── xcode-tools.nix
│   │   └── macos-utilities.nix
│   └── linux/                        # Linux-specific applications
│       ├── default.nix
│       ├── flatpak.nix
│       ├── appimage.nix
│       ├── gaming.nix
│       └── linux-utilities.nix
├── modules/                          # Core system modules
│   ├── common/                       # Cross-platform base configuration
│   │   ├── default.nix
│   │   ├── fonts.nix
│   │   ├── xdg.nix
│   │   └── locale.nix
│   ├── darwin/                       # macOS system configuration
│   │   ├── default.nix
│   │   ├── window-management/
│   │   │   ├── default.nix
│   │   │   ├── yabai.nix
│   │   │   └── skhd.nix
│   │   ├── system-settings.nix
│   │   └── services.nix
│   ├── linux/                        # Linux system configuration
│   │   ├── default.nix
│   │   ├── window-management/
│   │   │   ├── default.nix
│   │   │   ├── i3.nix
│   │   │   └── rofi.nix
│   │   ├── gtk.nix
│   │   ├── services.nix
│   │   └── hardware.nix
│   └── nixos/                        # NixOS system configuration (unchanged)
├── profiles/                         # User profiles and presets
│   ├── workstation.nix              # Full development setup
│   ├── minimal.nix                  # Minimal setup
│   ├── media-production.nix         # Media creation focus
│   └── server.nix                   # Server configuration
├── hosts/                           # Host-specific configurations
│   ├── macbook-air/
│   │   ├── default.nix
│   │   └── hardware.nix
│   ├── linux-desktop/
│   │   ├── default.nix
│   │   └── hardware.nix
│   └── nixos-server/
│       ├── default.nix
│       └── hardware.nix
└── lib/                             # Custom library functions
    ├── default.nix
    ├── mkUser.nix
    └── options.nix
```

## Migration Strategy

### Phase 1: Create New Structure
1. Create `applications/` directory with proper categorization
2. Break down large files into focused modules
3. Create proper `default.nix` files for each category

### Phase 2: Move Applications
1. Extract applications from `modules/common/default.nix`
2. Create individual application modules
3. Update imports to use new structure

### Phase 3: Reorganize System Modules
1. Clean up `modules/` to focus on system configuration
2. Move application-specific configs to `applications/`
3. Create `profiles/` for different use cases

### Phase 4: Create Host Configurations
1. Extract host-specific settings
2. Create `hosts/` directory for machine-specific configs
3. Update flake.nix to use new structure

### Phase 5: Update Build System
1. Update flake.nix to use new modular structure
2. Create helper functions for easier configuration
3. Update build scripts 