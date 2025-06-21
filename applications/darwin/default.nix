{ config, lib, pkgs, ... }:

{
  imports = [
    ./homebrew.nix
    ./mas-apps.nix
    ./xcode-tools.nix
    ./macos-utilities.nix
  ];

  # macOS-specific packages that work well through Nix
  home.packages = with pkgs; [
    # Window management
    aerospace         # AeroSpace tiling window manager
    
    # macOS utilities
    m-cli             # Swiss army knife for macOS
    mas               # Mac App Store CLI
    
    # Development tools
    cocoapods         # Dependency manager for Swift and Objective-C
    xcodes            # Manage Xcode versions
  ];
} 