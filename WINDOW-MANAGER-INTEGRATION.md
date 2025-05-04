# Window Manager Integration with Nix

This document explains how the Yabai and SKHD window managers are integrated with the Nix configuration system.

## Overview

We've created a hybrid approach where the window managers are:
1. **Installed through Nix/Home Manager** (as packages)
2. **Configured externally** (for better reliability and permissions handling)

## How It Works

### 1. Nix Configuration

In `home.nix`, window managers are included as packages but not managed by Home Manager:

```nix
# Window managers are installed but not managed by Home Manager
programs.yabai.enable = false; # Managed externally for better stability
programs.skhd.enable = false;  # Managed externally for better stability

# Required packages are still installed
home.packages = with pkgs; [
  yabai  # Tiling window manager
  skhd   # Hotkey daemon
  # ...other packages...
];
```

### 2. External Configuration

External configuration is managed through:
- Configuration files in `scripts/yabairc` and `scripts/skhdrc`
- LaunchAgent files in `scripts/com.koekeishiya.yabai.plist` and via SKHD's native service management
- Installation script in `scripts/install-window-managers.sh`

### 3. Post-Rebuild Integration

After each `home-manager switch` (when you run `scripts/rebuild.sh`):
1. The `post-rebuild-hooks.sh` script is automatically executed
2. It checks if window managers are configured for external management
3. If so, it runs the `install-window-managers.sh` script to set up LaunchAgents and configurations

## Why This Approach?

We use this hybrid approach because:

1. **Permission Handling**: macOS has strict security requirements for window managers
2. **Service Management**: SKHD has its own service management that works better than LaunchAgents
3. **Configuration Reloading**: This enables hot-reloading of configurations
4. **Stability**: External management prevents Home Manager restarts from disrupting window management

## Manual Update Process

If you need to manually update the window manager configuration:

1. Edit the configuration files:
   - `/Users/jacksonmiller/nix-config/scripts/yabairc`
   - `/Users/jacksonmiller/nix-config/scripts/skhdrc`

2. Run the installation script:
   ```bash
   /Users/jacksonmiller/nix-config/scripts/install-window-managers.sh
   ```

3. For SKHD only, you can hot-reload the configuration:
   ```bash
   skhd --reload
   ```

## Troubleshooting

See `README-WINDOW-MANAGERS.md` for detailed troubleshooting steps and configuration options.

## Files

- `/Users/jacksonmiller/nix-config/scripts/install-window-managers.sh`: Main installation script
- `/Users/jacksonmiller/nix-config/scripts/post-rebuild-hooks.sh`: Post-rebuild integration
- `/Users/jacksonmiller/nix-config/scripts/com.koekeishiya.yabai.plist`: Yabai LaunchAgent
- `/Users/jacksonmiller/nix-config/scripts/yabairc`: Yabai configuration
- `/Users/jacksonmiller/nix-config/scripts/skhdrc`: SKHD configuration
- `/Users/jacksonmiller/nix-config/scripts/skhd-cheatsheet.md`: Keyboard shortcut reference