#!/bin/bash

echo "Setting up SKHD configuration..."

# Ensure we have the necessary directories
mkdir -p ~/.config/skhd

# Copy our configuration file
cp ~/nix-config/skhdrc ~/.config/skhd/skhdrc
chmod 644 ~/.config/skhd/skhdrc

# Install skhd if not already installed
if ! command -v skhd &> /dev/null; then
    echo "SKHD not found, installing with brew..."
    brew install koekeishiya/formulae/skhd
fi

# Stop existing service if running
brew services stop skhd || true

# Clean up any existing pid files
rm -f /tmp/skhd_*.pid || true
rm -f /tmp/skhd.pid || true

# Start the service
echo "Starting SKHD service..."
brew services start skhd

# Check the status
echo "SKHD service status:"
brew services list | grep skhd

echo "SKHD setup complete!"
echo "To verify configuration: skhd -V"
echo "To reload configuration after changes: skhd -r"

# Check for common issues
if [ ! -f ~/.config/skhd/skhdrc ]; then
    echo "ERROR: Configuration file not found at ~/.config/skhd/skhdrc"
fi

if ! pgrep -x "skhd" > /dev/null; then
    echo "WARNING: SKHD process not running!"
else
    echo "Success! SKHD process is running."
fi