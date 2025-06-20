{ config, lib, pkgs, ... }:

{
  # macOS-specific system settings and defaults
  targets.darwin = {
    currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = true;
    
    # macOS system defaults
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