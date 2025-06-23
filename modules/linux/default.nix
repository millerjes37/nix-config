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
  # Common Linux-specific packages (avoid duplicates with common and linux-apps)
  home.packages = with pkgs; [
    # System utilities (unique to Linux desktop integration)
    pavucontrol      # Audio control
    blueman          # Bluetooth manager
    
    # Window management tools (X11 specific)
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
        
        # Images -> GIMP for editing, EOG for viewing
        "image/jpeg" = "gimp.desktop";
        "image/png" = "gimp.desktop";
        "image/gif" = "gimp.desktop";
        "image/bmp" = "gimp.desktop";
        "image/tiff" = "gimp.desktop";
        "image/webp" = "gimp.desktop";
        "image/svg+xml" = "org.inkscape.Inkscape.desktop";
        
        # RAW files -> Darktable
        "image/x-canon-cr2" = "darktable.desktop";
        "image/x-canon-crw" = "darktable.desktop";
        "image/x-nikon-nef" = "darktable.desktop";
        "image/x-sony-arw" = "darktable.desktop";
        "image/x-adobe-dng" = "darktable.desktop";
        
        # Video -> Kdenlive for editing, VLC for viewing
        "video/mp4" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
        "video/avi" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
        "video/mkv" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
        "video/mov" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
        "video/webm" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
        "video/x-matroska" = "vlc.desktop";
        
        # Audio -> Audacity for editing
        "audio/wav" = "audacity.desktop";
        "audio/mp3" = ["audacity.desktop" "vlc.desktop"];
        "audio/ogg" = ["audacity.desktop" "vlc.desktop"];
        "audio/flac" = ["audacity.desktop" "vlc.desktop"];
        "audio/mpeg" = "vlc.desktop";
        
        # Security -> KeePassXC
        "application/x-keepass2" = "org.keepassxc.KeePassXC.desktop";
        "application/x-keepassxc" = "org.keepassxc.KeePassXC.desktop";
      };
    };
  };
}