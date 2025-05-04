#!/bin/bash

echo "Setting up Yabai configuration..."

# Copy our configuration file
cp ~/nix-config/yabairc ~/.yabairc
chmod +x ~/.yabairc

# Install yabai if not already installed
if ! command -v yabai &> /dev/null; then
    echo "Yabai not found, installing with brew..."
    brew install koekeishiya/formulae/yabai
fi

# Stop existing service if running
brew services stop yabai || true

# Start the service
echo "Starting Yabai service..."
brew services start yabai

# Check the status
echo "Yabai service status:"
brew services list | grep yabai

echo "Yabai setup complete!"

# Check for common issues
if [ ! -f ~/.yabairc ]; then
    echo "ERROR: Configuration file not found at ~/.yabairc"
fi

if ! pgrep -x "yabai" > /dev/null; then
    echo "WARNING: Yabai process not running!"
else
    echo "Success! Yabai process is running."
fi