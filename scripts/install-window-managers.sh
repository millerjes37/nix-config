#!/bin/bash
set -e

# Script to install Yabai and SKHD LaunchAgents with proper permissions
# This script must be run with sudo privileges

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
YABAI_PLIST="$SCRIPT_DIR/com.koekeishiya.yabai.plist"
SKHD_PLIST="$SCRIPT_DIR/com.koekeishiya.skhd.plist"
YABAI_CONFIG_DIR="$HOME/.config/yabai"
SKHD_CONFIG_DIR="$HOME/.config/skhd"
YABAI_CONFIG="$SCRIPT_DIR/yabairc"
SKHD_CONFIG="$SCRIPT_DIR/skhdrc"

# Create config directories if they don't exist
mkdir -p "$YABAI_CONFIG_DIR"
mkdir -p "$SKHD_CONFIG_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Copy our local config files
if [ -f "$YABAI_CONFIG" ]; then
    cp "$YABAI_CONFIG" "$YABAI_CONFIG_DIR/yabairc"
    chmod +x "$YABAI_CONFIG_DIR/yabairc"
    echo "Yabairc installed successfully."
else
    # Fallback to using Nix config if available
    if [ -f "/etc/profiles/per-user/$USER/.config/yabai/yabairc" ]; then
        cp "/etc/profiles/per-user/$USER/.config/yabai/yabairc" "$YABAI_CONFIG_DIR/yabairc"
        chmod +x "$YABAI_CONFIG_DIR/yabairc"
        echo "Using Nix-generated yabairc config."
    else
        echo "Error: No yabairc configuration file found!"
        exit 1
    fi
fi

if [ -f "$SKHD_CONFIG" ]; then
    cp "$SKHD_CONFIG" "$SKHD_CONFIG_DIR/skhdrc"
    echo "Skhdrc installed successfully."
else
    # Fallback to using Nix config if available
    if [ -f "/etc/profiles/per-user/$USER/.config/skhd/skhdrc" ]; then
        cp "/etc/profiles/per-user/$USER/.config/skhd/skhdrc" "$SKHD_CONFIG_DIR/skhdrc"
        echo "Using Nix-generated skhdrc config."
    else
        echo "Error: No skhdrc configuration file found!"
        exit 1
    fi
fi

# Create yabai LaunchAgent with correct path
cat > "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.koekeishiya.yabai</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jacksonmiller/.nix-profile/bin/yabai</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/jacksonmiller/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/jacksonmiller/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
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

chown "$USER:staff" "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist"
chmod 644 "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist"

# Unload if already loaded
launchctl unload "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist" 2>/dev/null || true

# Clean up any stale PID files for SKHD
SKHD_PID_FILE="/tmp/skhd_$USER.pid"
if [ -f "$SKHD_PID_FILE" ]; then
    echo "Found stale SKHD PID file, cleaning up..."
    rm -f "$SKHD_PID_FILE"
fi

# Ensure SKHD is fully stopped
if pgrep -x skhd >/dev/null; then
    echo "SKHD is running, stopping it..."
    pkill -x skhd
    sleep 1
fi

# For SKHD, use its own service management
if skhd --stop-service 2>/dev/null; then
    echo "Stopped existing SKHD service"
fi

if skhd --uninstall-service 2>/dev/null; then
    echo "Uninstalled existing SKHD service"
fi

# Install SKHD service using its own command
skhd --install-service
echo "Installed SKHD service"

# Run Yabai directly if LaunchAgent fails
if ! launchctl load "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist"; then
    echo "Failed to load Yabai with LaunchAgent, starting directly..."
    pkill -x yabai 2>/dev/null || true
    /Users/jacksonmiller/.nix-profile/bin/yabai &
    disown
    echo "Yabai started directly"
else
    echo "Yabai loaded successfully with LaunchAgent"
fi

# Start SKHD service
skhd --start-service

echo "LaunchAgents installed and loaded for Yabai and SKHD."
echo ""
echo "Log file locations:"
echo "- Yabai: /tmp/yabai.err.log and /tmp/yabai.out.log"
echo "- SKHD: /tmp/skhd_$USER.err.log and /tmp/skhd_$USER.out.log"
echo ""
echo "IMPORTANT: You need to grant accessibility permissions for Yabai and SKHD."
echo "1. Go to System Settings -> Privacy & Security -> Privacy -> Accessibility"
echo "2. Click the + button to add applications"
echo "3. Navigate to /run/current-system/sw/bin/ and add both yabai and skhd"
echo ""
echo "Quick SKHD Commands:"
echo "- Reload config: skhd --reload"
echo "- Restart service: skhd --restart-service" 
echo "- View keycodes: skhd -o"
echo ""
echo "To verify services are running:"
echo "- Yabai: launchctl list | grep koekeishiya"
echo "- SKHD: ps aux | grep skhd"
echo ""
echo "A keyboard shortcut cheat sheet is available at:"
echo "$SCRIPT_DIR/skhd-cheatsheet.md"