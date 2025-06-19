# KeePassXC Configuration

This configuration sets up KeePassXC as the primary password manager across all platforms (Linux, macOS) using Nix and Home Manager.

## Features

### Cross-Platform Support
- **Linux**: Full integration with system secret service (FdoSecrets)
- **macOS**: Native app installation with file associations for `.kdbx` files
- **Unified Configuration**: Same settings applied across all platforms

### Security Features
- Auto-lock after 4 minutes of inactivity
- Auto-lock when screen locks
- Clipboard clearing (10 seconds for passwords, 5 seconds for search)
- Secure password hiding in UI
- Browser integration with confirmation prompts

### Browser Integration
- Supports all major browsers (Firefox, Chrome, Safari, etc.)
- Shows notifications for browser requests
- Allows database unlocking from browser
- URL scheme matching for better security

### Password Generation
- 20-character passwords by default
- Includes special characters, numbers, and mixed case
- Excludes similar-looking characters
- Strong defaults for secure password generation

## File Locations

### Configuration Files
- **Linux**: `~/.config/keepassxc/keepassxc.ini`
- **macOS**: `~/Library/Preferences/org.keepassxc.KeePassXC.plist`

### Database Storage Recommendations
- `~/Documents/Passwords/` - For personal databases
- `~/Sync/Passwords/` - If using cloud sync (Dropbox, iCloud, etc.)

## Global Shortcuts

- **Auto-Type**: `Meta+Shift+A` (Super+Shift+A on Linux, Cmd+Shift+A on macOS)

## Migration from Other Password Managers

KeePassXC supports importing from:
- 1Password (.1pux and .opvault files)
- Bitwarden
- Proton Pass
- CSV files
- KeePass 1.x databases

## Browser Extension Setup

1. Install KeePassXC browser extension for your browser:
   - [Firefox](https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/) (Recommended)
   - [Chrome/Chromium](https://chrome.google.com/webstore/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk)
   - [Safari](https://apps.apple.com/us/app/keepassxc-password-manager/id1467342620)
   - **Zen Browser**: Uses Firefox extension (install from Firefox Add-ons)

2. Configure browser integration:
   - Open KeePassXC
   - Go to Tools → Settings → Browser Integration
   - Enable browser integration
   - Firefox integration is pre-configured in this setup
   - Zen browser works automatically with Firefox configuration
   - For other browsers, select them in the settings

3. Connect browser extension:
   - Click the KeePassXC extension icon in Firefox
   - Click "Connect" when prompted
   - Enter a name for the connection (e.g., "Firefox Primary")
   - Approve the connection in KeePassXC

### Firefox-Specific Features

KeePassXC is configured with enhanced Firefox integration:

- **Auto-detection**: Firefox is automatically detected and enabled
- **Path Configuration**: 
  - Linux: Uses the Nix-installed Firefox path
  - macOS: Uses the standard Firefox.app location
- **Security Settings**:
  - Notifications for browser requests
  - Database must be unlocked for access
  - No automatic access permissions
  - Expired credentials are not allowed
  - HTTP authentication support is disabled by default
  - Browser proxy support is enabled
  - Migration prompts are disabled

### Troubleshooting Firefox Integration

1. **Extension Not Connecting**:
   - Ensure KeePassXC is running
   - Check that browser integration is enabled in KeePassXC
   - Verify the Firefox extension is up to date
   - Try removing and re-adding the connection

2. **Database Not Unlocking**:
   - Check that "Unlock database" is enabled in browser settings
   - Ensure you're using the latest version of the extension
   - Try reconnecting the browser extension

3. **Passwords Not Auto-filling**:
   - Check that the URL matches exactly (including http/https)
   - Try clicking the KeePassXC extension icon to see available entries
   - Verify that the entry has the correct URL saved

4. **Common Issues**:
   - If the extension shows as "Not connected", restart both Firefox and KeePassXC
   - If auto-fill doesn't work, try manually clicking the extension icon
   - For new database entries, ensure URLs are saved with the entry

### Zen Browser Integration

Since Zen browser is based on Firefox, it uses the same native messaging configuration:

1. **Installation**:
   - Install the KeePassXC browser extension from Firefox Add-ons
   - The extension works the same as in Firefox
   - No additional configuration needed

2. **Configuration**:
   - Zen browser automatically uses the Firefox native messaging host
   - The configuration file at `~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json` serves both browsers
   - **Flatpak Installation**: If Zen browser is installed as a Flatpak, additional configurations are created:
     - `~/.var/app/app.zen_browser.zen/data/native-messaging-hosts/org.keepassxc.keepassxc_browser.json`
     - `~/.var/app/app.zen_browser.zen/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json`
   - All configurations automatically point to the Nix-provided proxy: `${pkgs.keepassxc}/bin/keepassxc-proxy`
   - KeePassXC is configured to use custom proxy location to prevent auto-detection of wrong paths

3. **Troubleshooting Zen Browser**:
   - If Zen browser can't connect to KeePassXC, restart both applications
   - Verify that browser integration is enabled in KeePassXC settings
   - Check that the extension is installed and enabled in Zen browser
   - The same troubleshooting steps for Firefox apply to Zen browser

## SSH Agent Integration (Optional)

To enable SSH key management:

1. Edit `modules/common/keepassxc.nix`
2. Set `SSHAgent.Enabled = true;`
3. Rebuild your configuration
4. Add SSH keys to your KeePassXC database

## Platform-Specific Notes

### Linux
- Integrates with system secret service (used by browsers, applications)
- File associations automatically set for `.kdbx` files
- System tray integration enabled

### macOS
- Available via both Nix package and Homebrew cask
- File associations configured for Finder
- Native macOS notifications and system integration

## Troubleshooting

### Browser Integration Not Working
1. Check that browser integration is enabled in KeePassXC settings
2. Ensure the browser extension is installed and enabled
3. Try reconnecting the browser extension

### Auto-Type Not Working on Linux
1. Install additional packages if needed: `xdotool`, `xclip`
2. Check window manager compatibility
3. Verify global shortcut isn't conflicting with other applications

### Database Not Auto-Opening
1. Check file permissions on database files
2. Verify `RememberLastDatabases = true` in settings
3. Ensure database files haven't moved locations

## Security Best Practices

1. **Use Strong Master Passwords**: Combine passphrases with special characters
2. **Enable Two-Factor Authentication**: Use key files or hardware tokens when available
3. **Regular Backups**: Keep encrypted backups of your database files
4. **Database Sync**: Use secure cloud storage with additional encryption
5. **Monitor Access**: Review browser integration permissions regularly

## Configuration Files

The main configuration is located in:
- `modules/common/keepassxc.nix` - Core KeePassXC settings
- `modules/linux/linux-apps.nix` - Linux-specific packages (deprecated, moved to common)
- `modules/darwin/apps.nix` - macOS-specific packages

To modify settings, edit the appropriate `.nix` file and rebuild your configuration with:

```bash
# For Home Manager
home-manager switch

# For NixOS system
sudo nixos-rebuild switch

# For nix-darwin
darwin-rebuild switch
``` 