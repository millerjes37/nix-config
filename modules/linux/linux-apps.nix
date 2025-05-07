{ config, lib, pkgs, ... }:

{
  # Linux-specific applications
  home.packages = with pkgs; [
    # Web browsers
    firefox
    chromium
    
    # Office
    libreoffice
    okular         # PDF viewer
    
    # Media
    vlc            # Video player
    mpv            # Video player
    gimp           # Image editor
    inkscape       # Vector graphics
    obs-studio     # Screen recording
    
    # Communication
    slack
    zoom-us
    discord
    
    # System tools
    htop           # Process viewer
    neofetch       # System info
    arandr         # Display manager GUI
    gnome.gnome-disk-utility # Disk management
    
    # Security
    keepassxc      # Password manager
    
    # Utilities
    flameshot      # Screenshot tool
    redshift       # Blue light filter
    gnome.gnome-calculator
    
    # Development tools
    insomnia       # API client
    postman        # API client
    dbeaver        # Database GUI
    pgadmin4       # PostgreSQL admin
    
    # Fonts
    noto-fonts
    noto-fonts-cjk
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
  
  # File associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/pdf" = "okular.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/gif" = "org.gnome.eog.desktop";
      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "audio/mpeg" = "vlc.desktop";
      "text/plain" = "org.gnome.gedit.desktop";
    };
  };
}