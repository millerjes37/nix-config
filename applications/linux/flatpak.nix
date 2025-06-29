{ pkgs, ... }:

{
  # Comprehensive Flatpak configuration for Linux applications
  # Focus on applications not available or suboptimal in nixpkgs
  
  services.flatpak = {
    enable = true;
    packages = [
      # Web Browsers
      "app.zen_browser.zen"                 # Zen Browser - Firefox-based with privacy focus
      "org.mozilla.firefox"                # Firefox - backup browser
      "com.google.Chrome"                   # Chrome - for compatibility testing
      "com.brave.Browser"                   # Brave - privacy-focused browser
      
      # Productivity Suite
      "org.libreoffice.LibreOffice"         # LibreOffice - complete office suite
      "org.onlyoffice.desktopeditors"       # OnlyOffice - MS Office compatible
      "md.obsidian.Obsidian"                # Obsidian - note-taking and knowledge management
      "com.notion.Notion"                   # Notion - workspace and productivity
      
      # Communication
      "com.discordapp.Discord"              # Discord - gaming and community chat
      "com.slack.Slack"                     # Slack - team communication
      "us.zoom.Zoom"                        # Zoom - video conferencing
      "org.signal.Signal"                   # Signal - secure messaging
      "org.telegram.desktop"                # Telegram - messaging
      
      # Media and Entertainment
      "com.spotify.Client"                  # Spotify - music streaming
      "org.videolan.VLC"                    # VLC - media player
      "com.obsproject.Studio"               # OBS Studio - streaming and recording
      "org.audacityteam.Audacity"           # Audacity - audio editing
      "org.gimp.GIMP"                       # GIMP - image editing
      "org.inkscape.Inkscape"               # Inkscape - vector graphics
      "org.blender.Blender"                 # Blender - 3D creation suite
      
      # Development Tools
      "com.getpostman.Postman"              # Postman - API development
      "com.mongodb.Compass"                 # MongoDB Compass - database GUI
      "com.axosoft.GitKraken"               # GitKraken - Git GUI client
      "rest.insomnia.Insomnia"              # Insomnia - API testing
      
      # Gaming
      "com.valvesoftware.Steam"             # Steam - gaming platform
      "com.heroicgameslauncher.hgl"         # Heroic Games Launcher - Epic/GOG
      "net.lutris.Lutris"                   # Lutris - gaming on Linux
      
      # System Utilities
      "org.gnome.FileRoller"                # File Roller - archive manager
      "com.mattjakeman.ExtensionManager"    # GNOME Extension Manager
      "org.flameshot.Flameshot"             # Flameshot - screenshot tool
      "org.gnome.Calculator"                # Calculator
      "org.gnome.TextEditor"                # Text Editor
      "org.gnome.Evince"                    # Evince - PDF viewer
      
      # Finance and Crypto
      "org.electrum.electrum"               # Electrum - Bitcoin wallet
      
      # Education and Reference
      "org.anki.Anki"                       # Anki - spaced repetition learning
      "com.calibre_ebook.calibre"           # Calibre - ebook management
      
      # Privacy and Security
      "org.torproject.torbrowser-launcher"  # Tor Browser - anonymous browsing
      "org.keepassxc.KeePassXC"             # KeePassXC - password manager (backup)
      
      # Cloud Storage
      "com.dropbox.Client"                  # Dropbox - cloud storage
      "com.google.Drive"                    # Google Drive - cloud storage (if available)
      
      # Multimedia Production
      "org.kde.kdenlive"                    # Kdenlive - video editing
      "org.shotcut.Shotcut"                 # Shotcut - video editor
      "net.fasterland.converseen"           # Converseen - batch image converter
    ];
    
    # Flatpak repositories
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-beta";
        location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];
    
    # Update settings
    update = {
      auto = true;
      onActivation = true;
    };
  };
  
  # Install native packages that complement Flatpaks
  home.packages = with pkgs; [
    # Flatpak management tools
    flatpak                                 # Flatpak package manager
    gnome.gnome-software                    # Software center with Flatpak support
    
    # Font support for Flatpak applications
    fontconfig                              # Font configuration
    freetype                                # Font rendering
    
    # Theme support
    gnome.adwaita-icon-theme               # Icon theme for GTK apps
    gtk3                                   # GTK3 theme support
    gtk4                                   # GTK4 theme support
  ];

  # XDG Desktop Portal configuration for Flatpak applications
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk                # GTK portal
      xdg-desktop-portal-gnome              # GNOME portal (if using GNOME)
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      gnome = {
        default = [ "gnome" "gtk" ];
      };
    };
  };

  # Environment variables for Flatpak applications
  home.sessionVariables = {
    # Ensure Flatpak apps can find system fonts
    FONTCONFIG_PATH = "${pkgs.fontconfig.out}/etc/fonts";
    
    # Theme support for Flatpak apps
    GTK_THEME = "Adwaita:dark";
    
    # Icon theme
    ICON_THEME = "Adwaita";
  };

  # Shell aliases for Flatpak management
  programs.zsh.shellAliases = {
    # Flatpak shortcuts
    "fp" = "flatpak";
    "fp-install" = "flatpak install";
    "fp-remove" = "flatpak uninstall";
    "fp-update" = "flatpak update";
    "fp-list" = "flatpak list";
    "fp-search" = "flatpak search";
    "fp-info" = "flatpak info";
    "fp-run" = "flatpak run";
    
    # Application shortcuts
    "zen" = "flatpak run app.zen_browser.zen";
    "firefox" = "flatpak run org.mozilla.firefox";
    "chrome" = "flatpak run com.google.Chrome";
    "brave" = "flatpak run com.brave.Browser";
    "libreoffice" = "flatpak run org.libreoffice.LibreOffice";
    "obsidian" = "flatpak run md.obsidian.Obsidian";
    "discord" = "flatpak run com.discordapp.Discord";
    "slack" = "flatpak run com.slack.Slack";
    "spotify" = "flatpak run com.spotify.Client";
    "vlc" = "flatpak run org.videolan.VLC";
    "obs" = "flatpak run com.obsproject.Studio";
    "gimp" = "flatpak run org.gimp.GIMP";
    "postman" = "flatpak run com.getpostman.Postman";
    "steam" = "flatpak run com.valvesoftware.Steam";
  };
}