# This is the main system configuration file for macOS, managed by nix-darwin.
# It defines system-level settings, packages, and services.
# - `config`: Provides access to configuration options.
# - `pkgs`: Provides access to the Nix Packages collection for the system.
{ config, pkgs, ... }:

{
  # `services.yabai.enable` and `services.skhd.enable`:
  # These services are disabled as we're now using AeroSpace instead
  services.yabai.enable = false; # Replaced by AeroSpace
  services.skhd.enable = false;  # Not needed with AeroSpace

  # `environment.systemPackages`: This option lists packages that should be installed
  # system-wide, making them available to all users on the macOS system.
  # These packages are typically command-line tools or applications that integrate
  # at the system level.
  environment.systemPackages = with pkgs; [
    alacritty  # Alacritty terminal emulator.
    jq         # Command-line JSON processor, useful for scripts.
    aerospace  # AeroSpace tiling window manager (replacing yabai).
    # inputs.zen-browser.packages."${system}".default # Installs the Zen browser from the flake input.
    # Note: The `${system}` variable refers to the system architecture (e.g., "aarch64-darwin").
  ];

  # `nix-homebrew.enable`: This option enables the nix-homebrew integration.
  # When set to `true`, it allows managing Homebrew taps and packages declaratively
  # using the `homebrew` configuration section below.
  nix-homebrew.enable = true;

  # `homebrew`: Configuration section for declaratively managing Homebrew packages.
  # This approach allows you to specify Homebrew taps, formulae, and casks in your Nix configuration,
  # bridging the gap between Nix and Homebrew for macOS-specific software.
  homebrew = {
    # `enable`: Enables the Homebrew configuration. When set to `true`, the specified
    # taps, brews, and casks will be installed and managed.
    enable = true;

    # `brews`: A list of Homebrew formulae (packages) to install.
    # These are typically command-line tools and libraries that might not be available
    # or work well in Nix on macOS.
    brews = [
      # Add Homebrew formulae here if needed
      # Note: Many tools are now available through Nix, so prefer Nix when possible
    ];

    # `casks`: A list of Homebrew casks to install.
    # Casks are typically GUI applications for macOS.
    casks = [
      # Web Browsers
      "zen-browser"                   # Zen Browser - Firefox-based with privacy focus
      "firefox"                       # Firefox - backup browser  
      "google-chrome"                 # Chrome - for compatibility testing
      "brave-browser"                 # Brave - privacy-focused browser
      "arc"                           # Arc - modern browser with workspaces
      
      # Productivity Suite
      "libreoffice"                   # LibreOffice - complete office suite
      "onlyoffice"                    # OnlyOffice - MS Office compatible
      "obsidian"                      # Obsidian - note-taking and knowledge management
      "notion"                        # Notion - workspace and productivity
      "craft"                         # Craft - native macOS note-taking
      "bear"                          # Bear - markdown note-taking
      
      # Communication
      "discord"                       # Discord - gaming and community chat
      "slack"                         # Slack - team communication
      "zoom"                          # Zoom - video conferencing
      "signal"                        # Signal - secure messaging
      "telegram"                      # Telegram - messaging
      "whatsapp"                      # WhatsApp - messaging
      "skype"                         # Skype - video calling
      
      # Media and Entertainment
      "spotify"                       # Spotify - music streaming
      "vlc"                           # VLC - media player
      "iina"                          # IINA - modern media player for macOS
      "obs"                           # OBS Studio - streaming and recording
      "audacity"                      # Audacity - audio editing
      "logic-pro"                     # Logic Pro - professional audio (if available)
      "final-cut-pro"                 # Final Cut Pro - video editing (if available)
      
      # Graphics and Design
      "adobe-creative-cloud"          # Adobe Creative Cloud
      "figma"                         # Figma - design tool
      "sketch"                        # Sketch - vector design
      "affinity-designer"             # Affinity Designer - vector design
      "affinity-photo"                # Affinity Photo - photo editing
      "blender"                       # Blender - 3D creation suite
      "gimp"                          # GIMP - image editing
      "inkscape"                      # Inkscape - vector graphics
      
      # Development Tools
      "postman"                       # Postman - API development
      "insomnia"                      # Insomnia - API testing
      "mongodb-compass"               # MongoDB Compass - database GUI
      "sequel-pro"                    # Sequel Pro - MySQL GUI
      "tableplus"                     # TablePlus - database management
      "gitkraken"                     # GitKraken - Git GUI client
      "sourcetree"                    # SourceTree - Git GUI
      "docker"                        # Docker Desktop
      "virtualbox"                    # VirtualBox - virtualization
      "utm"                           # UTM - virtualization for Apple Silicon
      
      # System Utilities
      "alfred"                        # Alfred - productivity app
      "raycast"                       # Raycast - launcher and productivity
      "cleanmymac"                    # CleanMyMac - system cleaner
      "appcleaner"                    # AppCleaner - application uninstaller
      "the-unarchiver"                # The Unarchiver - archive utility
      "keka"                          # Keka - archive utility
      "finder-path"                   # FinderPath - copy path utility
      "path-finder"                   # Path Finder - file manager
      "forklift"                      # ForkLift - file manager and FTP client
      
      # Window Management (if not using AeroSpace)
      "rectangle"                     # Rectangle - window management
      "magnet"                        # Magnet - window management
      
      # Terminal and Shell
      "warp"                          # Warp - modern terminal
      "hyper"                         # Hyper - terminal built on web tech
      
      # Cloud Storage
      "google-drive"                  # Google Drive - cloud storage
      "dropbox"                       # Dropbox - cloud storage
      "onedrive"                      # OneDrive - Microsoft cloud storage
      "box-drive"                     # Box Drive - business cloud storage
      
      # Security and Privacy
      "1password"                     # 1Password - password manager
      "bitwarden"                     # Bitwarden - password manager
      "tor-browser"                   # Tor Browser - anonymous browsing
      "protonvpn"                     # ProtonVPN - VPN service
      "nordvpn"                       # NordVPN - VPN service
      
      # Gaming
      "steam"                         # Steam - gaming platform
      "epic-games"                    # Epic Games Launcher
      "gog-galaxy"                    # GOG Galaxy - DRM-free games
      "minecraft"                     # Minecraft
      
      # Finance and Crypto
      "electrum"                      # Electrum - Bitcoin wallet
      "exodus"                        # Exodus - crypto wallet
      
      # Education and Reference
      "anki"                          # Anki - spaced repetition learning
      "calibre"                       # Calibre - ebook management
      "kindle"                        # Kindle - ebook reader
      
      # Multimedia Production
      "handbrake"                     # HandBrake - video transcoder
      "permute-3"                     # Permute - media converter
      "imageoptim"                    # ImageOptim - image optimization
      "jpegoptim"                     # JPEGOptim - JPEG optimization
      
      # AI and Machine Learning
      "copilot"                       # GitHub Copilot (if available)
      "chatgpt"                       # ChatGPT desktop app (if available)
      
      # Specialized Tools
      "wireshark"                     # Wireshark - network analysis
      "charles"                       # Charles - web debugging proxy
      "proxyman"                      # Proxyman - HTTP debugging
      "paw"                           # Paw - API tool
      
      # Menu Bar Apps
      "bartender-4"                   # Bartender - menu bar organization
      "hidden-bar"                    # Hidden Bar - menu bar management
      "itsycal"                       # Itsycal - menu bar calendar
      "amphetamine"                   # Amphetamine - keep Mac awake
      
      # macOS Enhancements
      "karabiner-elements"            # Karabiner Elements - keyboard customization
      "bettertouchtool"               # BetterTouchTool - input customization
      "keyboard-maestro"              # Keyboard Maestro - automation
      "hazel"                         # Hazel - automated file organization
      "chronosync"                    # ChronoSync - file synchronization
      
      # Quick Look Plugins
      "qlcolorcode"                   # Quick Look syntax highlighting
      "qlstephen"                     # Quick Look plain text files
      "qlmarkdown"                    # Quick Look Markdown files
      "quicklook-json"                # Quick Look JSON files
      "qlimagesize"                   # Quick Look image dimensions
      "suspicious-package"            # Quick Look package contents
      
      # Fonts
      "font-fira-code"                # Fira Code font
      "font-jetbrains-mono"           # JetBrains Mono font
      "font-source-code-pro"          # Source Code Pro font
      "font-hack"                     # Hack font
    ];

    # `masApps`: A dictionary of Mac App Store applications to install.
    # The key is the name of the app, and the value is the App Store ID.
    masApps = {
      # Development Tools
      "Xcode" = 497799835;                    # Xcode - iOS/macOS development
      "TestFlight" = 899247664;               # TestFlight - beta testing
      "Simulator" = 1630308005;               # iOS Simulator
      
      # Productivity
      "Pages" = 409201541;                    # Pages - word processor
      "Numbers" = 409203825;                  # Numbers - spreadsheet
      "Keynote" = 409183694;                  # Keynote - presentations
      "GoodNotes 5" = 1444383602;             # GoodNotes - note-taking
      "Notability" = 360593530;               # Notability - note-taking
      "Things 3" = 904280696;                 # Things - task management
      "OmniFocus 3" = 1346203938;             # OmniFocus - task management
      "MindNode – Mind Map & Outline" = 1289197285; # MindNode - mind mapping
      
      # Utilities
      "Magnet" = 441258766;                   # Magnet - window management
      "CleanMyMac X" = 1339170533;            # CleanMyMac X - system cleaner
      "The Unarchiver" = 425424353;           # The Unarchiver - archive utility
      "1Blocker- Ad Blocker & Privacy" = 1365531024; # 1Blocker - ad blocker
      "Amphetamine" = 937984704;              # Amphetamine - prevent sleep
      "PopClip" = 445189367;                  # PopClip - text actions
      
      # Graphics and Design
      "Pixelmator Pro" = 1289583905;          # Pixelmator Pro - image editing
      "Affinity Designer" = 824171161;        # Affinity Designer - vector design
      "Affinity Photo" = 824183456;           # Affinity Photo - photo editing
      "Affinity Publisher" = 881418622;       # Affinity Publisher - desktop publishing
      "Logic Pro" = 634148309;                # Logic Pro - music production
      "Final Cut Pro" = 424389933;            # Final Cut Pro - video editing
      "Motion" = 434290957;                   # Motion - motion graphics
      "Compressor" = 424390742;               # Compressor - video compression
      
      # Communication
      "WhatsApp Messenger" = 1147396723;      # WhatsApp - messaging
      "Telegram" = 747648890;                 # Telegram - messaging
      "Signal" = 1553068068;                  # Signal - secure messaging
      
      # Entertainment
      "Apple Configurator 2" = 1037126344;    # Apple Configurator - device management
      
      # Finance
      "MoneyMoney" = 872698314;               # MoneyMoney - banking (German)
      
      # Security
      "1Password 7 - Password Manager" = 1333542190; # 1Password - password manager
      
      # Developer Utilities
      "SF Symbols" = 1531906653;              # SF Symbols - Apple's symbol library
      "System Information" = 1018496130;      # System Information - hardware info
      "Console" = 1004024928;                 # Console - system logs
      
      # Markdown and Writing
      "Marked 2" = 890031187;                 # Marked 2 - Markdown preview
      "iA Writer" = 775737590;                # iA Writer - distraction-free writing
      "Ulysses" = 1225570693;                 # Ulysses - writing app
      
      # Time Management
      "RescueTime" = 966285407;               # RescueTime - time tracking
      "Timing" = 1114928187;                  # Timing - automatic time tracking
      
      # Menu Bar
      "Hidden Bar" = 1452453066;              # Hidden Bar - menu bar management
      "One Switch" = 1480737355;              # One Switch - menu bar utility
      
      # Social Media
      "Tweetbot 3 for Twitter" = 1384080005; # Tweetbot - Twitter client
    };

    # `onActivation`: Configuration for what happens when the configuration is activated.
    onActivation = {
      # `autoUpdate`: Automatically update Homebrew packages when the configuration is applied.
      autoUpdate = true;
      # `upgrade`: Upgrade existing packages to their latest versions.
      upgrade = true;
      # `cleanup`: Clean up unused and old versions of packages.
      cleanup = "zap"; # "none", "uninstall", or "zap"
    };
  };

  # `fonts.packages`: Installs fonts system-wide.
  # These fonts will be available to all applications on the system.
  fonts.packages = [
    pkgs.fira-code
    pkgs.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # `system`: Configuration options specific to the Darwin (macOS) system.
  system = {
    # `stateVersion`: Defines the version of nix-darwin used for this configuration.
    # Update this when migrating to newer nix-darwin versions if breaking changes occur.
    stateVersion = 5;
  };

  # `nixpkgs`: Configuration for the Nix Packages collection.
  nixpkgs = {
    # `hostPlatform`: Specifies the platform (architecture and OS) for which packages should be built.
    # "aarch64-darwin" indicates Apple Silicon Macs (M1/M2/M3).
    hostPlatform = "aarch64-darwin";
    
    # `config`: Configuration options for nixpkgs behavior.
    config = {
      # `allowUnfree`: Allows the installation of packages with unfree licenses.
      # Set to `true` to enable proprietary software if needed.
      allowUnfree = true;
    };
  };

  # `nix`: Configuration for the Nix package manager itself.
  nix = {
    # `settings`: Low-level settings for the Nix daemon and package manager.
    settings = {
      # `experimental-features`: Enables experimental Nix features.
      # "nix-command" and "flakes" are commonly enabled for modern Nix usage.
      experimental-features = "nix-command flakes";
      # `trusted-users`: Users who are allowed to perform privileged Nix operations.
      # "@admin" refers to all users in the "admin" group (typical for macOS).
      trusted-users = [ "@admin" ];
    };
    
    # `gc`: Configuration for Nix garbage collection (cleaning up unused packages).
    gc = {
      # `automatic`: Automatically run garbage collection on a schedule.
      automatic = true;
      # `options`: Command-line options to pass to the `nix-collect-garbage` command.
      # "--delete-older-than 7d" removes packages older than 7 days.
      options = "--delete-older-than 7d";
    };
  };

  # `users.users.<username>`: Configuration for user accounts.
  users.users.jacksonmiller = {
    # `name`: The username of the user.
    name = "jacksonmiller";
    # `home`: The home directory path for the user.
    home = "/Users/jacksonmiller";
  };
}
