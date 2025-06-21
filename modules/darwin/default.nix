{ config, lib, pkgs, ... }:

{
  # Import system configuration modules
  imports = [
    # Core system configuration
    ../common/default.nix  # Common system modules
    
    # Window management
    ./window-management/default.nix
    
    # Darwin system settings
    ./system-settings.nix
    ./services.nix
  ];
  
  # Install macOS-specific packages
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