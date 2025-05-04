# macOS Window Manager Setup Guide

This guide explains how to properly set up the Yabai tiling window manager and SKHD hotkey daemon on macOS with the necessary permissions.

## Prerequisites

- Make sure Yabai and SKHD are installed (via Nix)
- Ensure your Mac has System Integrity Protection (SIP) partially disabled for Yabai to work fully (optional, see Yabai documentation)

## Installation Steps

1. **Run the installation script**

   ```bash
   cd ~/nix-config/scripts
   chmod +x install-window-managers.sh
   ./install-window-managers.sh
   ```

   This script will:
   - Create the necessary configuration directories
   - Copy configuration files to their proper locations
   - Set up LaunchAgents to start Yabai and SKHD automatically

2. **Grant Accessibility Permissions**

   macOS requires explicit permission for apps that control your computer:

   1. Go to **System Settings** > **Privacy & Security** > **Accessibility**
   2. Click the "+" button to add new apps
   3. Navigate to `/run/current-system/sw/bin` (or find the actual location with `which yabai` and `which skhd`)
   4. Add both `yabai` and `skhd` to the list
   5. Ensure the checkboxes next to both apps are checked

3. **Verify Service Status**

   Check if the services are running properly:

   ```bash
   launchctl list | grep koekeishiya
   ```

   You should see both `com.koekeishiya.yabai` and `com.koekeishiya.skhd` in the output.

4. **Check for Errors**

   If you encounter issues, check the log files:

   ```bash
   cat /tmp/yabai.err.log
   cat /tmp/skhd.err.log
   ```

## Keyboard Shortcuts Reference

The following are the key keyboard shortcuts configured for window management:

### Navigation (Focus)
- **Option + Command + H/J/K/L**: Focus window in direction (west/south/north/east)
- **Option + Command + N/P**: Focus next/previous window

### Moving Windows
- **Shift + Option + Command + H/J/K/L**: Move window in direction
- **Shift + Option + Command + [**: Move window to previous display
- **Shift + Option + Command + ]**: Move window to next display

### Resizing Windows
- **Option + Command + Arrow Keys**: Resize window in direction (larger increments)
- **Shift + Option + Command + Arrow Keys**: Fine resize window in direction (smaller increments)

### Window Properties
- **Option + Command + F**: Toggle float and center window
- **Option + Command + Z**: Toggle zoom-fullscreen
- **Option + Command + S**: Toggle split type (vertical/horizontal)
- **Option + Command + M**: Toggle native fullscreen
- **Option + Command + T**: Toggle sticky and topmost

### Space Management
- **Option + Command + 1-6**: Focus space 1-6
- **Shift + Option + Command + 1-6**: Move window to space 1-6 and follow
- **Option + Command + R**: Rotate space 90 degrees
- **Option + Command + B**: Balance space

### Application Launchers
- **Option + Command + Return**: Open Alacritty terminal
- **Option + Command + E**: Open Finder
- **Option + Command + W**: Open Safari
- **Option + Command + V**: Open Visual Studio Code

### System Commands
- **Option + Command + Q**: Close window
- **Option + Command + X**: Restart SKHD (reload configuration)

## Troubleshooting

### LaunchAgents Not Starting
- Check if LaunchAgents are properly installed: `ls -la ~/Library/LaunchAgents/`
- Force reload LaunchAgents:
  ```bash
  # For Yabai
  launchctl unload ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
  launchctl load ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
  
  # For SKHD (use built-in commands)
  skhd --stop-service
  skhd --start-service
  # or
  skhd --restart-service
  ```

### Running Yabai Directly (when LaunchAgent fails)
If the Yabai LaunchAgent fails to load (common on newer macOS versions):

```bash
# Kill any existing Yabai instances
pkill -x yabai

# Start Yabai directly in the background
/Users/jacksonmiller/.nix-profile/bin/yabai &
disown
```

### SKHD Specific Commands
SKHD comes with built-in service management:

- Install service: `skhd --install-service`
- Uninstall service: `skhd --uninstall-service`
- Start service: `skhd --start-service`
- Restart service: `skhd --restart-service`
- Stop service: `skhd --stop-service`
- Reload configuration (hot reload): `skhd --reload` or `skhd -r`
- Check configuration: `skhd -c ~/.config/skhd/skhdrc` (shows any errors)

When running as a service, log files can be found at:
- `/tmp/skhd_$USER.out.log` 
- `/tmp/skhd_$USER.err.log`

To observe keycodes (useful for creating custom shortcuts):
```bash
skhd -o
```
Then press any key combination to see its keycode and modifiers.

### Permission Issues
- Make sure the binaries have execute permissions
- Verify the LaunchAgent files have proper ownership and permissions (644)
- Check if the right applications were added to Accessibility permissions

### Configuration Issues
- Validate your configuration files with `yabai --check-config` and `skhd --parse <path-to-config>`
- Try running Yabai and SKHD manually to see any error output:
  ```bash
  /Users/jacksonmiller/.nix-profile/bin/yabai
  /Users/jacksonmiller/.nix-profile/bin/skhd
  ```
- Check error logs:
  ```bash
  cat /tmp/yabai.err.log
  cat /tmp/skhd_$USER.err.log
  ```

### SKHD Configuration Limitations
- SKHD **does not support shell variables** in its configuration file
- Always use full absolute paths in the SKHD configuration
- When editing the configuration, always use the absolute path to yabai:
  ```bash
  # CORRECT (use this):
  alt + cmd - h : /Users/jacksonmiller/.nix-profile/bin/yabai -m window --focus west
  
  # INCORRECT (will fail):
  alt + cmd - h : $YABAI_BIN -m window --focus west
  ```

### SKHD PID File Issues

If SKHD fails with an error like: `skhd: could not lock pid-file! abort..`, the PID file is likely stale. Fix it with:

```bash
# Quick fix for the PID file issue
rm -f /tmp/skhd_$USER.pid
skhd --restart-service

# Or use the utility script
fix-skhd
```

The `fix-skhd` utility script will automatically:
1. Stop any running SKHD instances
2. Remove the stale PID file
3. Clean up any log files
4. Reinstall and restart the SKHD service

## Live Configuration Editing

One of SKHD's most powerful features is the ability to hot reload its configuration without restarting the service. This makes experimenting with keyboard shortcuts much easier:

1. Edit your configuration file: `nano ~/.config/skhd/skhdrc`
2. Save the changes
3. Reload the configuration with: `skhd --reload` or `skhd -r`
4. Test your new shortcuts immediately

This allows for rapid iteration when setting up your perfect keyboard shortcut system. You can even add a keyboard shortcut to reload SKHD itself:

```
# Add to your skhdrc file:
alt + cmd - r : skhd --reload
```

## Additional Resources

- [Yabai Documentation](https://github.com/koekeishiya/yabai/wiki)
- [SKHD Documentation](https://github.com/koekeishiya/skhd)
- [Yabai Accessibility Permissions Guide](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition)
- [SKHD GitHub Repository](https://github.com/koekeishiya/skhd)
- [Community Configurations](https://github.com/search?q=skhdrc)