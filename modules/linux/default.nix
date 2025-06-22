{ config, lib, pkgs, inputs, ... }:

{
  # Import all Linux-specific modules
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak  # Flatpak support
    ../../modules/common/default.nix  # Common modules first
    ../../modules/common/keybindings.nix  # Shared keybindings
    ./i3.nix                         # Window manager
    ./rofi.nix                       # Application launcher
    ./gtk.nix                        # GTK theming
    ./linux-apps.nix                 # Linux-specific applications
    ./cursor.nix                     # Cursor AI editor with sandbox fixes
    ./flatpak.nix
    ./nixgl.nix                      # nixGL wrapper and packages
  ];
  
  # Common Linux-specific packages (avoid duplicates with common and linux-apps)
  home.packages = with pkgs; [
    # GUI tools
    firefox
    keepassxc
    libreoffice
    discord
    
    # System utilities (unique to Linux desktop integration)
    pavucontrol      # Audio control
    blueman          # Bluetooth manager
    
    # Window management tools (X11 specific)
    xclip            # Clipboard tool
    xdotool          # X11 automation
    xorg.xev         # X event viewer
    dunst            # Notification daemon
  ];
  
  # Enable XDG desktop integration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };
    
    # Consolidated file associations for Linux
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Development files -> Cursor (from cursor.nix)
        "text/plain" = "cursor.desktop";
        "text/x-python" = "cursor.desktop";
        "text/x-rust" = "cursor.desktop";
        "text/x-go" = "cursor.desktop";
        "text/x-javascript" = "cursor.desktop";
        "text/x-typescript" = "cursor.desktop";
        "application/json" = "cursor.desktop";
        "text/x-markdown" = "cursor.desktop";
        "text/x-yaml" = "cursor.desktop";
        "text/x-toml" = "cursor.desktop";
        
        # Web content -> Firefox
        "text/html" = "firefox.desktop";
        "text/xml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        
        # Documents -> LibreOffice/Okular
        "application/pdf" = "okular.desktop";
        
        # Images -> EOG for viewing
        "image/jpeg" = "org.gnome.eog.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "image/gif" = "org.gnome.eog.desktop";
        
        # Video -> VLC for viewing
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "audio/mpeg" = "vlc.desktop";
      };
    };
  };
}