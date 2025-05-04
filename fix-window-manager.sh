#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}====== FIXING WINDOW MANAGER CONFIG ======${NC}"

# Go to the nix-config directory
cd "$(dirname "$0")" || exit

# Check for yabai binary
if ! command -v yabai &> /dev/null; then
    echo -e "${RED}Error: yabai is not installed or not in your PATH${NC}"
    echo -e "${YELLOW}Please make sure yabai is installed via Nix or Homebrew${NC}"
    exit 1
fi

# Check for skhd binary
if ! command -v skhd &> /dev/null; then
    echo -e "${RED}Error: skhd is not installed or not in your PATH${NC}"
    echo -e "${YELLOW}Please make sure skhd is installed via Nix or Homebrew${NC}"
    exit 1
fi

# Create skhdrc file
echo -e "${YELLOW}Creating SKHD configuration with single option key bindings...${NC}"
cat > skhdrc << 'EOL'
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
echo -e "${YELLOW}Creating Yabai configuration...${NC}"
cat > yabairc << 'EOL'
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
chmod +x yabairc

# Create directories if they don't exist
mkdir -p ~/.config/skhd

# Copy config files to proper locations
echo -e "${YELLOW}Copying configurations to the right locations...${NC}"
cp skhdrc ~/.config/skhd/skhdrc
cp yabairc ~/.yabairc

# Fix permissions
chmod 644 ~/.config/skhd/skhdrc
chmod 755 ~/.yabairc

# Restart services
echo -e "${YELLOW}Restarting window manager services...${NC}"

# Stop SKHD
echo -e "${YELLOW}Stopping SKHD...${NC}"
pkill -9 skhd || true
sleep 1

# Stop Yabai
echo -e "${YELLOW}Stopping Yabai...${NC}"
pkill -9 yabai || true
sleep 1

# Start yabai
echo -e "${YELLOW}Starting Yabai...${NC}"
~/.yabairc &
sleep 1

# Start skhd
echo -e "${YELLOW}Starting SKHD...${NC}"
skhd -c ~/.config/skhd/skhdrc &
sleep 1

# Check if the services are running
echo -e "${YELLOW}Checking service status...${NC}"
if pgrep -x "yabai" > /dev/null; then
    echo -e "${GREEN}Yabai is running.${NC}"
else
    echo -e "${RED}Yabai is not running.${NC}"
fi

if pgrep -x "skhd" > /dev/null; then
    echo -e "${GREEN}SKHD is running.${NC}"
else
    echo -e "${RED}SKHD is not running.${NC}"
fi

echo -e "${BLUE}====== DONE ======${NC}"
echo -e "${GREEN}Remember to check for errors in the following log files:${NC}"
echo -e "${YELLOW}SKHD logs: skhd -v${NC}"
echo -e "${YELLOW}Yabai logs: tail -f /tmp/yabai.out.log${NC}"