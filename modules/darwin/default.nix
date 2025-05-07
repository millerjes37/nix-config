{ config, lib, pkgs, ... }:

{
  # Import all macOS-specific modules
  imports = [
    ../../modules/common/default.nix  # Common modules first
    ./yabai.nix       # Window manager
    ./skhd.nix        # Hotkey daemon
    ./apps.nix        # macOS applications
  ];
  
  # Install macOS-specific packages
  home.packages = with pkgs; [
    # Window management
    yabai             # Tiling window manager
    skhd              # Hotkey daemon
    
    # macOS utilities
    m-cli             # Swiss army knife for macOS
    mas               # Mac App Store CLI
    
    # Development tools
    cocoapods         # Dependency manager for Swift and Objective-C
    xcodes            # Manage Xcode versions
  ];
  
  # macOS-specific home manager settings
  targets.darwin = {
    currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = true;
    
    # Add more macOS defaults as needed
    defaults = {
      NSGlobalDomain = {
        # Finder behavior
        AppleShowAllExtensions = true;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        
        # Keyboard settings
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        
        # UI settings
        _HIHideMenuBar = false;
        AppleInterfaceStyle = "Dark";
      };
      
      "com.apple.finder" = {
        ShowStatusBar = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
        FXPreferredViewStyle = "Nlsv"; # List view
      };
      
      "com.apple.dock" = {
        autohide = true;
        show-recents = false;
        tilesize = 36;
        minimize-to-application = true;
      };
      
      "com.apple.Safari" = {
        ShowFullURLInSmartSearchField = true;
        ShowStatusBar = true;
      };
    };
  };
}