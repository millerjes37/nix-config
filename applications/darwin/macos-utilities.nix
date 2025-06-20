{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # macOS system utilities
    m-cli             # Swiss army knife for macOS (already in darwin/default.nix)
    # dockutil        # Dock management utility
    # defaultbrowser  # Set default browser from command line
    
    # Productivity tools for macOS
    # rectangle       # Window management (alternative to yabai for some users)
    # karabiner-elements # Keyboard customization
    
    # macOS-specific development tools
    # carthage        # Dependency manager for Cocoa
    # swiftlint       # Swift code style checker
    # swiftformat     # Swift code formatter
  ];
} 