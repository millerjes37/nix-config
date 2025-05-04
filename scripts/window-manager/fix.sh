#!/usr/bin/env bash
set -e

# Script to fix common window manager issues
# Combines fix-window-manager.sh and fix-skhd.sh into a single utility

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
source "$NIX_CONFIG_DIR/scripts/utils/common.sh"

function fix_skhd() {
  print_header "SKHD FIX UTILITY"
  
  # Step 1: Check if SKHD is running
  stop_process "skhd"
  
  # Step 2: Clean up PID file
  SKHD_PID_FILE="/tmp/skhd_$USER.pid"
  if [ -f "$SKHD_PID_FILE" ]; then
    print_step "Found SKHD PID file, removing it..."
    rm -f "$SKHD_PID_FILE"
  else
    print_success "No SKHD PID file found."
  fi
  
  # Step 3: Clean up LaunchAgent
  print_step "Removing SKHD service..."
  if skhd --uninstall-service 2>/dev/null; then
    print_success "Successfully uninstalled SKHD service."
  else
    print_warning "No SKHD service found or error uninstalling."
  fi
  
  # Step 4: Check for log files and remove them
  for log_file in /tmp/skhd*.log /tmp/skhd_$USER*.log; do
    if [ -f "$log_file" ]; then
      print_step "Removing log file: $log_file"
      rm -f "$log_file"
    fi
  done
  
  # Step 5: Reinstall SKHD service
  print_step "Reinstalling SKHD service..."
  skhd --install-service
  print_success "SKHD service installed."
  
  # Step 6: Start SKHD
  print_step "Starting SKHD..."
  skhd --start-service
  
  # Step 7: Verify SKHD is running
  sleep 1
  if pgrep -x skhd >/dev/null; then
    print_success "SKHD is now running successfully!"
  else
    print_error "Failed to start SKHD. Please check for errors."
    print_warning "Try running: skhd -V"
    exit 1
  fi
}

function fix_yabai() {
  print_header "YABAI FIX UTILITY"
  
  # Step 1: Check if Yabai is running
  stop_process "yabai"
  
  # Step 2: Clean up launchctl
  print_step "Unloading Yabai LaunchAgent if loaded..."
  launchctl unload ~/Library/LaunchAgents/com.koekeishiya.yabai.plist 2>/dev/null || true
  
  # Step 3: Check for log files and remove them
  for log_file in /tmp/yabai*.log; do
    if [ -f "$log_file" ]; then
      print_step "Removing log file: $log_file"
      rm -f "$log_file"
    fi
  done
  
  # Step 4: Load LaunchAgent
  print_step "Loading Yabai LaunchAgent..."
  if launchctl load ~/Library/LaunchAgents/com.koekeishiya.yabai.plist 2>/dev/null; then
    print_success "Yabai LaunchAgent loaded successfully."
  else
    print_warning "Failed to load Yabai with LaunchAgent, starting directly..."
    "$HOME/.yabairc" &
    disown
  fi
  
  # Step 5: Verify Yabai is running
  sleep 1
  if pgrep -x yabai >/dev/null; then
    print_success "Yabai is now running successfully!"
  else
    print_error "Failed to start Yabai. Please check for errors."
    print_warning "Try checking: /tmp/yabai.err.log"
    exit 1
  fi
}

function configure_from_scratch() {
  print_header "CONFIGURING WINDOW MANAGERS FROM SCRATCH"
  
  # Create skhdrc file
  print_step "Creating SKHD configuration..."
  cat > "$NIX_CONFIG_DIR/skhdrc" << 'EOL'
# Window Manager Hotkeys for SKHD (Simple Option Key Setup)

# -----------------------------------------------
# Window Focus (Navigate with Option)
# -----------------------------------------------
# Window focus with option + arrow keys
option - left  : yabai -m window --focus west || yabai -m display --focus west
option - down  : yabai -m window --focus south || yabai -m display --focus south
option - up    : yabai -m window --focus north || yabai -m display --focus north
option - right : yabai -m window --focus east || yabai -m display --focus east

# Cycle through windows in current space
option - n : yabai -m window --focus next || yabai -m window --focus first
option - p : yabai -m window --focus prev || yabai -m window --focus last

# -----------------------------------------------
# Space Management (Mission Control) with Option
# -----------------------------------------------
# Switch to Spaces 1-6 with just Option + number
option - 1 : yabai -m space --focus 1
option - 2 : yabai -m space --focus 2
option - 3 : yabai -m space --focus 3
option - 4 : yabai -m space --focus 4
option - 5 : yabai -m space --focus 5
option - 6 : yabai -m space --focus 6

# Move windows to spaces with Option + Shift + number
shift + option - 1 : yabai -m window --space 1; yabai -m space --focus 1
shift + option - 2 : yabai -m window --space 2; yabai -m space --focus 2
shift + option - 3 : yabai -m window --space 3; yabai -m space --focus 3
shift + option - 4 : yabai -m window --space 4; yabai -m space --focus 4
shift + option - 5 : yabai -m window --space 5; yabai -m space --focus 5
shift + option - 6 : yabai -m window --space 6; yabai -m space --focus 6

# -----------------------------------------------
# Window Management with Option
# -----------------------------------------------
# Make window fullscreen
option - f : yabai -m window --toggle zoom-fullscreen

# Float / unfloat window
option - t : yabai -m window --toggle float

# Window movement with option + shift + arrow keys
shift + option - left  : yabai -m window --warp west || yabai -m window --space prev
shift + option - down  : yabai -m window --warp south
shift + option - up    : yabai -m window --warp north
shift + option - right : yabai -m window --warp east || yabai -m window --space next

# Balance space layout
option - b : yabai -m space --balance

# Rotate space layout
option - r : yabai -m space --rotate 90

# Restart SKHD
option - x : skhd --restart-service

# Application Launchers with just option
option - return : open -a "Alacritty"
option - e : open -a "Finder"
option - w : open -a "Safari"
option - c : open -a "Visual Studio Code"

# -----------------------------------------------
# Window Arrangements
# -----------------------------------------------
# Center window
option - m : yabai -m window --grid 6:6:1:1:4:4
# Left half
option - 0x2F : yabai -m window --grid 1:2:0:0:1:1 # comma key
# Right half
option - 0x2B : yabai -m window --grid 1:2:1:0:1:1 # period key
EOL
  
  # Create yabairc file
  print_step "Creating Yabai configuration..."
  cat > "$NIX_CONFIG_DIR/yabairc" << 'EOL'
#!/usr/bin/env sh

# Set window management approach
yabai -m config layout bsp

# New window spawns to the right if vertical, or bottom if horizontal
yabai -m config window_placement second_child

# Padding between windows
yabai -m config top_padding 10
yabai -m config bottom_padding 10
yabai -m config left_padding 10
yabai -m config right_padding 10
yabai -m config window_gap 10

# Mouse support
yabai -m config mouse_follows_focus on
yabai -m config focus_follows_mouse autoraise

# Status update
echo "yabai configuration loaded.."
EOL
  
  # Make yabairc executable
  chmod +x "$NIX_CONFIG_DIR/yabairc"
  
  print_success "Configuration files created in $NIX_CONFIG_DIR"
  print_step "Run '$SCRIPT_DIR/setup.sh' to install these configurations"
}

function print_help() {
  print_header "WINDOW MANAGER FIX UTILITY HELP"
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --skhd-only     Fix only SKHD issues"
  echo "  --yabai-only    Fix only Yabai issues"
  echo "  --configure     Generate fresh configuration files"
  echo "  --help          Show this help message"
  echo
  echo "Running without options will fix both window managers"
}

# Main function to handle script operation
function main() {
  # Check for root privileges
  if [ "$EUID" -eq 0 ]; then
    print_error "Please don't run this script as root/sudo"
    exit 1
  fi
  
  case "$1" in
    --skhd-only)
      fix_skhd
      ;;
    --yabai-only)
      fix_yabai
      ;;
    --configure)
      configure_from_scratch
      ;;
    --help)
      print_help
      ;;
    *)
      # Default: fix both
      fix_yabai
      fix_skhd
      print_header "WINDOW MANAGER FIX COMPLETE"
      print_success "You can verify window managers are working by trying some keyboard shortcuts."
      ;;
  esac
}

# Run the main function with provided args
main "$@"