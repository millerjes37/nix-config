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
   - [Firefox](https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/)
   - [Chrome/Chromium](https://chrome.google.com/webstore/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk)
   - [Safari](https://apps.apple.com/us/app/keepassxc-password-manager/id1467342620)

2. Configure browser integration:
   - Open KeePassXC
   - Go to Tools → Settings → Browser Integration
   - Enable browser integration
   - Select your browsers

3. Connect browser extension:
   - Click the KeePassXC extension icon
   - Click "Connect" when prompted
   - Enter a name for the connection
   - Approve the connection in KeePassXC

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