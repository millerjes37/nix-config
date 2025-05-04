# macOS Window Manager Setup Guide

This guide helps you set up yabai and skhd on macOS, which requires special permissions to work correctly.

## New Single Option Key Bindings

This configuration now uses simpler key bindings that only require the **Option key** for most operations:

- **Switch Desktops**: `Option + 1-6` to switch to space 1-6
- **Move Windows**: `Option + Shift + 1-6` to move window to space 1-6
- **Focus Windows**: `Option + Arrow Keys` to focus window in direction
- **Window Actions**: `Option + F` for fullscreen, `Option + T` for float

See the complete cheatsheet in `scripts/skhd-cheatsheet.md` for all available keybindings.

## 1. Installing the Tools

The tools are already installed via your Nix configuration, but they need proper permissions to work on macOS.

## 2. Setting up Accessibility Permissions

Both yabai and skhd require accessibility permissions to control windows and intercept keyboard shortcuts:

1. Open **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
2. Click the lock icon at the bottom and enter your password
3. Click the "+" button to add applications
4. Navigate to:
   - `/run/current-system/sw/bin/yabai` or `/Users/jacksonmiller/.nix-profile/bin/yabai`
   - `/run/current-system/sw/bin/skhd` or `/Users/jacksonmiller/.nix-profile/bin/skhd`
5. Add both applications to the list of apps allowed to control your computer
6. Restart your computer for the permissions to take effect

## 3. Creating Launch Agents

To start the services on login, create these launch agent files:

1. Create a directory for your launch agents:
```bash
mkdir -p ~/Library/LaunchAgents
```

2. Create a yabai launch agent file:
```bash
cat > ~/Library/LaunchAgents/org.nixos.yabai.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.nixos.yabai</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jacksonmiller/.nix-profile/bin/yabai</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/jacksonmiller/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/yabai.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/yabai.err.log</string>
</dict>
</plist>
EOF
```

3. Create an skhd launch agent file:
```bash
cat > ~/Library/LaunchAgents/org.nixos.skhd.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.nixos.skhd</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jacksonmiller/.nix-profile/bin/skhd</string>
        <string>-c</string>
        <string>/Users/jacksonmiller/.config/skhd/skhdrc</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/jacksonmiller/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/skhd.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/skhd.err.log</string>
</dict>
</plist>
EOF
```

## 4. Starting the Services

1. Load the launch agents:
```bash
launchctl load ~/Library/LaunchAgents/org.nixos.yabai.plist
launchctl load ~/Library/LaunchAgents/org.nixos.skhd.plist
```

2. Check if they are running:
```bash
launchctl list | grep org.nixos
```

3. If you need to restart the services:
```bash
launchctl unload ~/Library/LaunchAgents/org.nixos.yabai.plist
launchctl unload ~/Library/LaunchAgents/org.nixos.skhd.plist
launchctl load ~/Library/LaunchAgents/org.nixos.yabai.plist
launchctl load ~/Library/LaunchAgents/org.nixos.skhd.plist
```

## 5. SIP Considerations for Yabai

For full functionality, yabai may require System Integrity Protection (SIP) to be partially disabled. However, this step is optional and comes with security implications.

## 6. Troubleshooting

If the services aren't running properly:

1. Check the log files:
```bash
cat /tmp/yabai.err.log
cat /tmp/skhd.err.log
```

2. Verify permissions:
   - Re-check System Preferences → Security & Privacy → Privacy → Accessibility
   - Ensure both applications are in the list and checked

3. Common errors:
   - "Failed to connect to socket" - yabai isn't running or has crashed
   - "Must be run with accessibility access" - skhd needs permissions

4. Run the manual start commands to see direct output:
```bash
/Users/jacksonmiller/.nix-profile/bin/yabai
/Users/jacksonmiller/.nix-profile/bin/skhd -c /Users/jacksonmiller/.config/skhd/skhdrc
```

## 7. Configuration Files

Your configuration files are stored at:

- yabai: `~/.yabairc`
- skhd: `~/.config/skhd/skhdrc`

You can edit these files to customize your window management and hotkeys.