{ config, lib, pkgs, ... }:

{
  # Cross-platform application aliases and shortcuts
  # Provides consistent commands across macOS, Linux, and NixOS
  # Automatically detects platform and uses appropriate installation method
  
  programs.zsh.shellAliases = lib.mkMerge [
    # Universal browser shortcuts
    {
      # Primary browser (Zen Browser)
      "browser" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Zen Browser'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run app.zen_browser.zen")
      ];
      "zen" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Zen Browser'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run app.zen_browser.zen")
      ];
      
      # Firefox (backup browser)
      "firefox" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Firefox")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.mozilla.firefox")
      ];
      "ff" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Firefox")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.mozilla.firefox")
      ];
      
      # Chrome (compatibility testing)
      "chrome" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Google Chrome'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.google.Chrome")
      ];
      
      # Brave (privacy)
      "brave" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Brave Browser'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.brave.Browser")
      ];
    }
    
    # Productivity applications
    {
      # Office suite
      "office" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a LibreOffice")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.libreoffice.LibreOffice")
      ];
      "libreoffice" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a LibreOffice")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.libreoffice.LibreOffice")
      ];
      "writer" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a LibreOffice --args --writer")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.libreoffice.LibreOffice --writer")
      ];
      "calc" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a LibreOffice --args --calc")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.libreoffice.LibreOffice --calc")
      ];
      "impress" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a LibreOffice --args --impress")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.libreoffice.LibreOffice --impress")
      ];
      
      # Note-taking
      "obsidian" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Obsidian")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run md.obsidian.Obsidian")
      ];
      "notes" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Obsidian")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run md.obsidian.Obsidian")
      ];
      "notion" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Notion")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.notion.Notion")
      ];
    }
    
    # Communication applications
    {
      "discord" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Discord")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.discordapp.Discord")
      ];
      "slack" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Slack")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.slack.Slack")
      ];
      "zoom" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a zoom.us")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run us.zoom.Zoom")
      ];
      "signal" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Signal")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.signal.Signal")
      ];
      "telegram" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Telegram")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.telegram.desktop")
      ];
    }
    
    # Media applications
    {
      "spotify" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Spotify")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.spotify.Client")
      ];
      "music" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Spotify")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.spotify.Client")
      ];
      "vlc" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a VLC")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.videolan.VLC")
      ];
      "video" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a VLC")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.videolan.VLC")
      ];
      "obs" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'OBS Studio'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.obsproject.Studio")
      ];
      "stream" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'OBS Studio'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.obsproject.Studio")
      ];
    }
    
    # Development applications
    {
      "postman" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Postman")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.getpostman.Postman")
      ];
      "api" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Postman")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.getpostman.Postman")
      ];
      "insomnia" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Insomnia")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run rest.insomnia.Insomnia")
      ];
      "mongo" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'MongoDB Compass'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.mongodb.Compass")
      ];
      "gitkraken" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a GitKraken")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.axosoft.GitKraken")
      ];
    }
    
    # Graphics and design
    {
      "gimp" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a GIMP")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.gimp.GIMP")
      ];
      "inkscape" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Inkscape")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.inkscape.Inkscape")
      ];
      "blender" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Blender")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.blender.Blender")
      ];
      "figma" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Figma")
        (lib.mkIf pkgs.stdenv.isLinux "firefox https://figma.com")
      ];
    }
    
    # System utilities and tools
    {
      # File management
      "files" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Finder")
        (lib.mkIf pkgs.stdenv.isLinux "nautilus")
      ];
      "finder" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Finder")
        (lib.mkIf pkgs.stdenv.isLinux "nautilus")
      ];
      
      # Quick open current directory
      "here" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open .")
        (lib.mkIf pkgs.stdenv.isLinux "nautilus .")
      ];
      
      # Archive management
      "archive" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'The Unarchiver'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.gnome.FileRoller")
      ];
      "extract" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'The Unarchiver'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.gnome.FileRoller")
      ];
      
      # Screenshots
      "screenshot" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "screencapture -i")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.flameshot.Flameshot")
      ];
      "ss" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "screencapture -i")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run org.flameshot.Flameshot")
      ];
    }
    
    # Cloud storage
    {
      "googledrive" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Google Drive'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.google.Drive 2>/dev/null || xdg-open https://drive.google.com")
      ];
      "gdrive" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Google Drive'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.google.Drive 2>/dev/null || xdg-open https://drive.google.com")
      ];
      "dropbox" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Dropbox")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.dropbox.Client")
      ];
    }
    
    # Gaming
    {
      "steam" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a Steam")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.valvesoftware.Steam")
      ];
      "epic" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "open -a 'Epic Games Launcher'")
        (lib.mkIf pkgs.stdenv.isLinux "flatpak run com.heroicgameslauncher.hgl")
      ];
    }
    
    # Quick system commands
    {
      # System information
      "sysinfo" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "system_profiler SPHardwareDataType")
        (lib.mkIf pkgs.stdenv.isLinux "inxi -Fxz")
      ];
      
      # Network information  
      "myip" = "curl -s ifconfig.me";
      "localip" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "ipconfig getifaddr en0")
        (lib.mkIf pkgs.stdenv.isLinux "ip route get 1.1.1.1 | grep -oP 'src \\K\\S+'")
      ];
      
      # Quick access to common directories
      "downloads" = "cd ~/Downloads";
      "documents" = "cd ~/Documents";
      "desktop" = "cd ~/Desktop";
      "projects" = "cd ~/Projects 2>/dev/null || cd ~/projects 2>/dev/null || cd ~";
      "dev" = "cd ~/Development 2>/dev/null || cd ~/dev 2>/dev/null || cd ~/Projects 2>/dev/null || cd ~";
      
      # Quick edit configuration
      "edit-nix" = "${pkgs.helix}/bin/helix ${config.home.homeDirectory}/nix-config";
      "edit-config" = "${pkgs.helix}/bin/helix ${config.home.homeDirectory}/nix-config";
      "nix-config" = "cd ${config.home.homeDirectory}/nix-config";
      
      # System maintenance
      "cleanup" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin "sudo rm -rf ~/.Trash/* && brew cleanup && nix-collect-garbage -d")
        (lib.mkIf pkgs.stdenv.isLinux "sudo rm -rf ~/.local/share/Trash/* && flatpak uninstall --unused && nix-collect-garbage -d")
      ];
      
      # Rebuild system configuration
      "rebuild" = "${config.home.homeDirectory}/nix-config/scripts/rebuild.sh";
      "switch" = "${config.home.homeDirectory}/nix-config/scripts/rebuild.sh";
    }
  ];

  # Environment variables for cross-platform compatibility
  home.sessionVariables = {
    # Browser preferences
    BROWSER = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin "open")
      (lib.mkIf pkgs.stdenv.isLinux "flatpak run app.zen_browser.zen")
    ];
    
    # Default applications
    DEFAULT_BROWSER = "zen";
    DEFAULT_EDITOR = "helix";
    DEFAULT_TERMINAL = "alacritty";
    
    # Development environment
    PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
    DEV_DIR = "${config.home.homeDirectory}/Development";
  };

  # Create standard directories
  home.activation.createDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create standard development directories
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Projects"
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Development"
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Scripts"
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.local/bin"
    
    # Set proper permissions
    $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/Projects"
    $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/Development"
    $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/Scripts"
    $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/.local/bin"
  '';
}