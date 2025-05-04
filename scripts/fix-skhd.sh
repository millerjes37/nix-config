#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====== SKHD FIX UTILITY ======${NC}"

# Check for root privileges
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Please don't run this script as root/sudo${NC}"
  exit 1
fi

# Step 1: Check if SKHD is running
echo -e "${YELLOW}Checking if SKHD is running...${NC}"
if pgrep -x skhd >/dev/null; then
  echo -e "${YELLOW}Found running SKHD process, stopping it...${NC}"
  pkill -x skhd
  sleep 1
else
  echo -e "${GREEN}No running SKHD process found.${NC}"
fi

# Step 2: Clean up PID file
SKHD_PID_FILE="/tmp/skhd_$USER.pid"
if [ -f "$SKHD_PID_FILE" ]; then
  echo -e "${YELLOW}Found SKHD PID file, removing it...${NC}"
  rm -f "$SKHD_PID_FILE"
else
  echo -e "${GREEN}No SKHD PID file found.${NC}"
fi

# Step 3: Clean up LaunchAgent
echo -e "${YELLOW}Removing SKHD service...${NC}"
if skhd --uninstall-service 2>/dev/null; then
  echo -e "${GREEN}Successfully uninstalled SKHD service.${NC}"
else
  echo -e "${YELLOW}No SKHD service found or error uninstalling.${NC}"
fi

# Step 4: Check for log files and remove them
for log_file in /tmp/skhd*.log /tmp/skhd_$USER*.log; do
  if [ -f "$log_file" ]; then
    echo -e "${YELLOW}Removing log file: $log_file${NC}"
    rm -f "$log_file"
  fi
done

# Step 5: Reinstall SKHD service
echo -e "${YELLOW}Reinstalling SKHD service...${NC}"
skhd --install-service
echo -e "${GREEN}SKHD service installed.${NC}"

# Step 6: Start SKHD
echo -e "${YELLOW}Starting SKHD...${NC}"
skhd --start-service

# Step 7: Verify SKHD is running
sleep 1
if pgrep -x skhd >/dev/null; then
  echo -e "${GREEN}SKHD is now running successfully!${NC}"
else
  echo -e "${RED}Failed to start SKHD. Please check for errors.${NC}"
  echo -e "${YELLOW}Try running: skhd -V${NC}"
  exit 1
fi

echo -e "${BLUE}====== SKHD FIX COMPLETE ======${NC}"
echo -e "${GREEN}You can verify SKHD is working by trying some keyboard shortcuts.${NC}"