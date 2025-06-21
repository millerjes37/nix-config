#!/usr/bin/env bash

# Migration script from yabai/skhd to aerospace
# This script safely removes yabai/skhd and sets up aerospace

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

print_step() {
    echo -e "${YELLOW}=> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to stop and clean up yabai
cleanup_yabai() {
    print_step "Stopping and cleaning up yabai..."
    
    # Stop yabai process
    if pgrep -x yabai >/dev/null; then
        print_step "Stopping yabai process..."
        pkill -x yabai
        sleep 2
    fi
    
    # Unload yabai LaunchAgent
    local yabai_plist="$HOME/Library/LaunchAgents/com.koekeishiya.yabai.plist"
    if [ -f "$yabai_plist" ]; then
        print_step "Unloading yabai LaunchAgent..."
        launchctl unload "$yabai_plist" 2>/dev/null || true
        rm -f "$yabai_plist"
        print_success "Removed yabai LaunchAgent"
    fi
    
    # Clean up yabai log files
    rm -f /tmp/yabai*.log
    
    print_success "Yabai cleanup completed"
}

# Function to stop and clean up skhd
cleanup_skhd() {
    print_step "Stopping and cleaning up skhd..."
    
    # Stop skhd using its service management
    if command -v skhd >/dev/null 2>&1; then
        skhd --stop-service 2>/dev/null || true
        skhd --uninstall-service 2>/dev/null || true
    fi
    
    # Stop skhd process manually if still running
    if pgrep -x skhd >/dev/null; then
        print_step "Stopping skhd process..."
        pkill -x skhd
        sleep 2
    fi
    
    # Clean up skhd PID file
    rm -f "/tmp/skhd_$USER.pid"
    
    # Clean up skhd log files
    rm -f /tmp/skhd*.log
    
    print_success "SKHD cleanup completed"
}

# Function to back up old configurations
backup_configs() {
    print_step "Backing up old configurations..."
    
    local backup_dir="$HOME/.config/window-manager-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup yabairc
    if [ -f "$HOME/.yabairc" ]; then
        cp "$HOME/.yabairc" "$backup_dir/"
        print_success "Backed up .yabairc"
    fi
    
    # Backup skhdrc
    if [ -f "$HOME/.config/skhd/skhdrc" ]; then
        cp "$HOME/.config/skhd/skhdrc" "$backup_dir/"
        print_success "Backed up skhdrc"
    fi
    
    # Backup root level configs if they exist
    if [ -f "$HOME/nix-config/yabairc" ]; then
        cp "$HOME/nix-config/yabairc" "$backup_dir/"
        print_success "Backed up root yabairc"
    fi
    
    if [ -f "$HOME/nix-config/skhdrc" ]; then
        cp "$HOME/nix-config/skhdrc" "$backup_dir/"
        print_success "Backed up root skhdrc"
    fi
    
    print_success "Configurations backed up to: $backup_dir"
}

# Function to clean up old config files
cleanup_configs() {
    print_step "Cleaning up old configuration files..."
    
    # Remove old yabai and skhd modules (we've already replaced them)
    if [ -f "$HOME/nix-config/modules/darwin/window-management/yabai.nix" ]; then
        rm -f "$HOME/nix-config/modules/darwin/window-management/yabai.nix"
        print_success "Removed old yabai.nix module"
    fi
    
    if [ -f "$HOME/nix-config/modules/darwin/window-management/skhd.nix" ]; then
        rm -f "$HOME/nix-config/modules/darwin/window-management/skhd.nix"
        print_success "Removed old skhd.nix module"
    fi
    
    # Remove root level config files (they're no longer needed)
    if [ -f "$HOME/nix-config/yabairc" ]; then
        rm -f "$HOME/nix-config/yabairc"
        print_success "Removed root yabairc"
    fi
    
    if [ -f "$HOME/nix-config/skhdrc" ]; then
        rm -f "$HOME/nix-config/skhdrc"
        print_success "Removed root skhdrc"
    fi
    
    print_success "Configuration cleanup completed"
}

# Function to rebuild the nix configuration
rebuild_nix() {
    print_step "Rebuilding nix configuration with aerospace..."
    
    cd "$HOME/nix-config"
    
    if [ -f "scripts/rebuild.sh" ]; then
        print_step "Running rebuild script..."
        ./scripts/rebuild.sh
    else
        print_step "Running home-manager switch directly..."
        home-manager switch --flake .
    fi
    
    print_success "Nix configuration rebuild completed"
}

# Function to start aerospace
start_aerospace() {
    print_step "Starting aerospace..."
    
    # Aerospace should start automatically due to start-at-login = true in config
    # But we can also start it manually
    if command -v aerospace >/dev/null 2>&1; then
        # Open aerospace app (it will run in background)
        open -a AeroSpace 2>/dev/null || true
        sleep 2
        
        if pgrep -i aerospace >/dev/null; then
            print_success "AeroSpace started successfully!"
        else
            print_warning "AeroSpace may need to be started manually. Try running 'open -a AeroSpace'"
        fi
    else
        print_error "AeroSpace not found. Make sure the rebuild completed successfully."
        return 1
    fi
}

# Function to display post-migration instructions
display_instructions() {
    print_header "POST-MIGRATION INSTRUCTIONS"
    
    echo -e "${YELLOW}1. Grant Accessibility Permissions:${NC}"
    echo "   - Go to System Settings > Privacy & Security > Accessibility"
    echo "   - Add AeroSpace and grant it permission to control your computer"
    echo ""
    
    echo -e "${YELLOW}2. Test Your Configuration:${NC}"
    echo "   - Try Alt+Enter to open a terminal"
    echo "   - Try Alt+1-6 to switch workspaces"  
    echo "   - Try Alt+Arrow keys to focus windows"
    echo ""
    
    echo -e "${YELLOW}3. Customize Your Configuration:${NC}"
    echo "   - Your aerospace config is at ~/.aerospace.toml"
    echo "   - Edit modules/darwin/window-management/aerospace.nix to change defaults"
    echo "   - Run 'home-manager switch --flake .' to apply changes"
    echo ""
    
    echo -e "${YELLOW}4. Useful Commands:${NC}"
    echo "   - 'aerospace reload-config' to reload configuration"
    echo "   - 'aerospace list-windows --all' to list all windows"
    echo "   - 'aerospace --help' for more commands"
    echo ""
    
    echo -e "${GREEN}Migration completed successfully!${NC}"
    echo -e "${GREEN}Welcome to AeroSpace! 🚀${NC}"
}

# Main migration function
main() {
    print_header "MIGRATING FROM YABAI/SKHD TO AEROSPACE"
    
    echo "This script will:"
    echo "1. Stop and clean up yabai and skhd"
    echo "2. Back up your old configurations"
    echo "3. Clean up old configuration files"
    echo "4. Rebuild your nix configuration with aerospace"
    echo "5. Start aerospace"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
    
    # Check if we're in the right directory
    if [ ! -f "$HOME/nix-config/flake.nix" ]; then
        print_error "Please run this script from your nix-config directory or ensure it exists at ~/nix-config"
        exit 1
    fi
    
    # Perform migration steps
    backup_configs
    cleanup_yabai
    cleanup_skhd
    cleanup_configs
    
    print_step "Migration steps completed. Now rebuilding configuration..."
    rebuild_nix
    
    print_step "Starting AeroSpace..."
    start_aerospace
    
    display_instructions
}

# Run main function
main "$@" 