{ config, lib, pkgs, ... }:

{
  # Syncthing - Cross-platform file synchronization
  # Enables automatic synchronization of files across multiple devices
  
  # Install Syncthing
  home.packages = with pkgs; [
    syncthing                       # P2P file synchronization tool
    syncthing-gtk                   # GTK GUI for Syncthing (Linux)
  ];

  # Syncthing service configuration
  services.syncthing = {
    enable = true;
    
    # User and directory configuration
    user = config.home.username;
    dataDir = "${config.home.homeDirectory}/.local/share/syncthing";
    configDir = "${config.home.homeDirectory}/.config/syncthing";
    
    # GUI settings
    guiAddress = "127.0.0.1:8384";  # Local access only for security
    
    # Network settings
    settings = {
      # Global configuration
      globalAnnounceEnabled = true;
      localAnnounceEnabled = true;
      relaysEnabled = true;
      natEnabled = true;
      urAccepted = -1;              # Disable usage reporting
      restartOnWakeup = true;
      startBrowserOnLaunch = false; # Don't auto-open browser
      
      # GUI configuration
      gui = {
        enabled = true;
        address = "127.0.0.1:8384";
        user = "";                  # No authentication for local access
        password = "";              # No authentication for local access
        theme = "dark";             # Dark theme
        debugging = false;
        insecureAdminAccess = true; # Allow local access without auth
      };
      
      # Options
      options = {
        # Listening addresses
        listenAddresses = [
          "default"                 # Use default discovery
          "tcp://0.0.0.0:22000"    # TCP listening
          "quic://0.0.0.0:22000"   # QUIC listening (faster)
        ];
        
        # Global discovery and relay settings
        globalAnnounceServers = [
          "default"
        ];
        relayServers = [
          "default"
        ];
        
        # Performance settings
        maxSendKbps = 0;            # No upload limit
        maxRecvKbps = 0;            # No download limit
        reconnectionIntervalS = 60;
        relaysEnabled = true;
        natEnabled = true;
        crashReportingEnabled = false;
        stunKeepaliveStartS = 180;
        stunKeepaliveMinS = 20;
        stunTimeoutS = 30;
        
        # File handling
        tempIndexMinBlocks = 10;
        unackedNotificationIDs = [];
        trafficClass = 0;
        defaultFolderPath = "${config.home.homeDirectory}/Sync";
        setLowPriority = false;
        minHomeDiskFree = {
          unit = "%";
          value = 1;
        };
        
        # Security and privacy
        urAccepted = -1;            # Disable anonymous usage reporting
        urSeen = 3;
        upgradeIntervalH = 12;      # Check for updates every 12 hours
        upgradeToPreReleases = false;
        autoUpgradeEnabled = false; # Disable auto-updates (managed by Nix)
      };
      
      # Default folder configuration template
      folders = {
        # Documents folder - synced across all devices
        "documents" = {
          id = "documents";
          label = "Documents";
          path = "${config.home.homeDirectory}/Documents/Sync";
          type = "sendreceive";
          rescanIntervalS = 3600;   # Scan for changes every hour
          fsWatcherEnabled = true;  # Watch for file system changes
          fsWatcherDelayS = 10;     # Delay before processing changes
          ignorePerms = lib.mkIf pkgs.stdenv.isDarwin true; # Ignore permissions on macOS
          autoNormalize = true;     # Normalize unicode
          minDiskFree = {
            unit = "%";
            value = 1;
          };
          versioning = {
            type = "staggered";     # Keep multiple versions
            params = {
              cleanInterval = "3600";
              maxAge = "31536000";  # 1 year
            };
          };
        };
        
        # KeePassXC database folder - high priority sync
        "keepassxc" = {
          id = "keepassxc";
          label = "KeePassXC Database";
          path = "${config.home.homeDirectory}/.keepassxc-sync";
          type = "sendreceive";
          rescanIntervalS = 300;    # Scan every 5 minutes for quick sync
          fsWatcherEnabled = true;  # Immediate file watching
          fsWatcherDelayS = 1;      # Quick response to changes
          ignorePerms = lib.mkIf pkgs.stdenv.isDarwin true;
          autoNormalize = true;
          minDiskFree = {
            unit = "%";
            value = 1;
          };
          versioning = {
            type = "simple";        # Simple versioning for databases
            params = {
              keep = "10";          # Keep 10 versions
            };
          };
        };
        
        # Configuration files sync
        "configs" = {
          id = "configs";
          label = "Configuration Files";
          path = "${config.home.homeDirectory}/.config-sync";
          type = "sendreceive";
          rescanIntervalS = 1800;   # Scan every 30 minutes
          fsWatcherEnabled = true;
          fsWatcherDelayS = 5;
          ignorePerms = lib.mkIf pkgs.stdenv.isDarwin true;
          autoNormalize = true;
          minDiskFree = {
            unit = "%";
            value = 1;
          };
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "7776000";   # 90 days
            };
          };
        };
      };
    };
    
    # Override settings for different platforms
    overrideFolders = lib.mkMerge [
      # macOS-specific folder overrides
      (lib.mkIf pkgs.stdenv.isDarwin {
        # Add macOS-specific ignore patterns
      })
      
      # Linux-specific folder overrides  
      (lib.mkIf pkgs.stdenv.isLinux {
        # Add Linux-specific configurations
      })
    ];
    
    # Override devices (to be configured per-system)
    overrideDevices = {
      # Device configurations will be added here
      # This is where you'll add your specific device IDs
    };
  };

  # Create sync directories
  home.file = {
    # Create Documents sync directory
    "Documents/Sync/.keep".text = "";
    
    # Create KeePassXC sync directory
    ".keepassxc-sync/.keep".text = "";
    
    # Create config sync directory
    ".config-sync/.keep".text = "";
    
    # Create a README file for sync directories
    "Documents/Sync/README.md".text = ''
      # Syncthing Synchronized Documents

      This directory is automatically synchronized across all your devices using Syncthing.
      
      ## Folders:
      - `Documents/Sync/` - General document synchronization
      - `~/.keepassxc-sync/` - KeePassXC password database synchronization
      - `~/.config-sync/` - Configuration file synchronization
      
      ## Usage:
      - Place files you want to sync across devices in these folders
      - KeePassXC databases are automatically synced with conflict resolution
      - Configuration files can be selectively synced
      
      ## Web Interface:
      Access Syncthing's web interface at: http://localhost:8384
      
      ## Security:
      - All synchronization is end-to-end encrypted
      - No data is stored on third-party servers
      - Direct device-to-device synchronization
    '';
  };

  # Platform-specific service management
  # On macOS, use launchd; on Linux, use systemd
  home.activation = {
    syctthingDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Ensure sync directories exist with proper permissions
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Documents/Sync"
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.keepassxc-sync"
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config-sync"
      
      # Set appropriate permissions
      $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/Documents/Sync"
      $DRY_RUN_CMD chmod 700 "${config.home.homeDirectory}/.keepassxc-sync"
      $DRY_RUN_CMD chmod 755 "${config.home.homeDirectory}/.config-sync"
    '';
  };

  # Shell aliases for Syncthing management
  programs.zsh.shellAliases = {
    # Syncthing control
    "sync-status" = "curl -s http://localhost:8384/rest/system/status | ${pkgs.jq}/bin/jq";
    "sync-gui" = "open http://localhost:8384";  # macOS/Linux compatible
    "sync-restart" = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin "launchctl stop home-manager.syncthing && launchctl start home-manager.syncthing")
      (lib.mkIf pkgs.stdenv.isLinux "systemctl --user restart syncthing")
    ];
    "sync-logs" = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin "tail -f ~/.local/share/syncthing/syncthing.log")
      (lib.mkIf pkgs.stdenv.isLinux "journalctl --user -u syncthing -f")
    ];
    
    # Quick folder access
    "cd-sync" = "cd ${config.home.homeDirectory}/Documents/Sync";
    "cd-keepass-sync" = "cd ${config.home.homeDirectory}/.keepassxc-sync";
    "cd-config-sync" = "cd ${config.home.homeDirectory}/.config-sync";
  };

  # Environment variables
  home.sessionVariables = {
    SYNCTHING_HOME = "${config.home.homeDirectory}/.local/share/syncthing";
    SYNCTHING_CONFIG = "${config.home.homeDirectory}/.config/syncthing";
  };
}