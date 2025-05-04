#!/usr/bin/env bash
set -e

# Script to set up both Yabai and SKHD with proper configurations and service management
# Combines functionality from multiple scripts into a single, unified setup script

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
source "$NIX_CONFIG_DIR/scripts/utils/common.sh"

# Define paths
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
YABAI_CONFIG_DIR="$HOME/.config/yabai"
SKHD_CONFIG_DIR="$HOME/.config/skhd"
YABAI_LOCAL_CONFIG="$NIX_CONFIG_DIR/yabairc"
SKHD_LOCAL_CONFIG="$NIX_CONFIG_DIR/skhdrc"

# Create launch agents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

function setup_yabai() {
  print_header "SETTING UP YABAI"

  # Create config directory if it doesn't exist
  mkdir -p "$YABAI_CONFIG_DIR"

  # Check for yabai binary
  if ! command -v yabai &> /dev/null; then
    print_error "Error: yabai is not installed or not in your PATH"
    print_warning "Please make sure yabai is installed via Nix or Homebrew"
    exit 1
  fi

  # Copy yabairc file
  if [ -f "$YABAI_LOCAL_CONFIG" ]; then
    print_step "Using local yabairc configuration..."
    cp "$YABAI_LOCAL_CONFIG" ~/.yabairc
    chmod +x ~/.yabairc
    print_success "Yabairc installed successfully."
  else
    # Fallback to using Nix config if available
    if [ -f "/etc/profiles/per-user/$USER/.config/yabai/yabairc" ]; then
      print_step "Using Nix-generated yabairc config..."
      cp "/etc/profiles/per-user/$USER/.config/yabai/yabairc" ~/.yabairc
      chmod +x ~/.yabairc
      print_success "Using Nix-generated yabairc config."
    else
      print_error "No yabairc configuration file found!"
      exit 1
    fi
  fi

  # Create yabai LaunchAgent with correct path
  print_step "Creating Yabai LaunchAgent..."
  cat > "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.koekeishiya.yabai</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/$USER/.nix-profile/bin/yabai</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/$USER/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
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

  # Stop existing processes if running
  print_step "Stopping Yabai if running..."
  pkill -x yabai 2>/dev/null || true
  launchctl unload "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist" 2>/dev/null || true
  sleep 1

  # Load LaunchAgent or start directly
  print_step "Starting Yabai service..."
  if ! launchctl load "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist"; then
    print_warning "Failed to load Yabai with LaunchAgent, starting directly..."
    /Users/$USER/.nix-profile/bin/yabai &
    disown
    print_success "Yabai started directly"
  else
    print_success "Yabai loaded successfully with LaunchAgent"
  fi
}

function setup_skhd() {
  print_header "SETTING UP SKHD"

  # Create config directory if it doesn't exist
  mkdir -p "$SKHD_CONFIG_DIR"

  # Check for skhd binary
  if ! command -v skhd &> /dev/null; then
    print_error "Error: skhd is not installed or not in your PATH"
    print_warning "Please make sure skhd is installed via Nix or Homebrew"
    exit 1
  fi

  # Copy skhdrc file
  if [ -f "$SKHD_LOCAL_CONFIG" ]; then
    print_step "Using local skhdrc configuration..."
    cp "$SKHD_LOCAL_CONFIG" "$SKHD_CONFIG_DIR/skhdrc"
    chmod 644 "$SKHD_CONFIG_DIR/skhdrc"
    print_success "Skhdrc installed successfully."
  else
    # Fallback to using Nix config if available
    if [ -f "/etc/profiles/per-user/$USER/.config/skhd/skhdrc" ]; then
      print_step "Using Nix-generated skhdrc config..."
      cp "/etc/profiles/per-user/$USER/.config/skhd/skhdrc" "$SKHD_CONFIG_DIR/skhdrc"
      chmod 644 "$SKHD_CONFIG_DIR/skhdrc"
      print_success "Using Nix-generated skhdrc config."
    else
      print_error "No skhdrc configuration file found!"
      exit 1
    fi
  fi

  # Clean up any stale PID files for SKHD
  SKHD_PID_FILE="/tmp/skhd_$USER.pid"
  if [ -f "$SKHD_PID_FILE" ]; then
    print_step "Found stale SKHD PID file, cleaning up..."
    rm -f "$SKHD_PID_FILE"
  fi

  # Stop existing service if running
  stop_process "skhd"

  # For SKHD, use its own service management
  if skhd --stop-service 2>/dev/null; then
    print_success "Stopped existing SKHD service"
  fi

  if skhd --uninstall-service 2>/dev/null; then
    print_success "Uninstalled existing SKHD service"
  fi

  # Install SKHD service using its own command
  print_step "Installing SKHD service..."
  skhd --install-service
  print_success "Installed SKHD service"

  # Start SKHD service
  print_step "Starting SKHD service..."
  skhd --start-service
  print_success "SKHD service started"
}

function check_status() {
  print_header "CHECKING SERVICE STATUS"

  # Check if the services are running
  print_step "Verifying services are running..."
  
  if pgrep -x "yabai" > /dev/null; then
    print_success "Yabai is running."
  else
    print_error "Yabai is not running."
  fi

  if pgrep -x "skhd" > /dev/null; then
    print_success "SKHD is running."
  else
    print_error "SKHD is not running."
  fi

  print_step "Log file locations:"
  echo "- Yabai: /tmp/yabai.err.log and /tmp/yabai.out.log"
  echo "- SKHD: /tmp/skhd_$USER.err.log and /tmp/skhd_$USER.out.log"
}

function print_help() {
  print_header "WINDOW MANAGER SETUP HELP"
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --yabai-only       Setup only Yabai"
  echo "  --skhd-only        Setup only SKHD"
  echo "  --status           Check services status"
  echo "  --restart          Restart both services"
  echo "  --help             Show this help message"
  echo
  echo "Running without options will setup both Yabai and SKHD"
}

function restart_services() {
  print_header "RESTARTING SERVICES"
  
  # Restart Yabai
  print_step "Restarting Yabai..."
  pkill -x yabai 2>/dev/null || true
  launchctl unload "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist" 2>/dev/null || true
  sleep 1
  launchctl load "$LAUNCH_AGENTS_DIR/com.koekeishiya.yabai.plist"
  print_success "Yabai restarted"
  
  # Restart SKHD
  print_step "Restarting SKHD..."
  skhd --restart-service
  print_success "SKHD restarted"
  
  # Check status
  check_status
}

function print_permissions_help() {
  print_header "PERMISSIONS INFORMATION"
  
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
  
  if [ -f "$SCRIPT_DIR/skhd-cheatsheet.md" ]; then
    echo ""
    echo "A keyboard shortcut cheat sheet is available at:"
    echo "$SCRIPT_DIR/skhd-cheatsheet.md"
  fi
}

# Main function to handle script operation
function main() {
  case "$1" in
    --yabai-only)
      setup_yabai
      check_status
      ;;
    --skhd-only)
      setup_skhd
      check_status
      ;;
    --status)
      check_status
      ;;
    --restart)
      restart_services
      ;;
    --help)
      print_help
      ;;
    *)
      # Default: setup both
      print_header "SETTING UP WINDOW MANAGERS"
      setup_yabai
      setup_skhd
      check_status
      print_permissions_help
      ;;
  esac
  
  print_header "SETUP COMPLETE"
}

# Run the main function with provided args
main "$@"