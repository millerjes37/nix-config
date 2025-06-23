{ config, lib, pkgs, ... }:

{
  # Linux-specific applications
  home.packages = with pkgs; [
    # Web browsers
    firefox
    chromium
    
    # Office
    libreoffice
    kdePackages.okular  # PDF viewer
    
    # Media (core tools - comprehensive suite in common/media-suite.nix)
    vlc            # Video player
    mpv            # Video player
    # Note: GIMP, Inkscape, OBS Studio now configured in media-suite.nix
    # with professional workflows and templates
    
    # Communication
    slack
    zoom-us
    discord
    
    # System tools
    htop           # Process viewer
    neofetch       # System info
    arandr         # Display manager GUI
    gnome-disk-utility # Disk management
    
    # Security tools
    # Note: KeePassXC is now configured via the common module with Home Manager
    # keepassxc is handled by programs.keepassxc in modules/common/keepassxc.nix
    
    # Utilities
    flameshot      # Screenshot tool
    redshift       # Blue light filter
    gnome-calculator
    
    # Development tools
    insomnia       # API client
    postman        # API client
    dbeaver-bin    # Database GUI
    pgadmin4       # PostgreSQL admin
    
    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    ubuntu_font_family
  ];
  
  # Configure Flameshot (screenshot tool)
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = false;
        showStartupLaunchMessage = false;
        uiColor = "#8ec07c";
        contrastUiColor = "#282828";
      };
    };
  };
  
  # Redshift - blue light filter
  services.redshift = {
    enable = true;
    latitude = 40.7;  # Set to your location
    longitude = -74.0; # Set to your location
    temperature = {
      day = 6500;
      night = 3500;
    };
  };
  
  # NOTE: File associations moved to modules/linux/default.nix to avoid conflicts
  # This ensures centralized MIME type management
}