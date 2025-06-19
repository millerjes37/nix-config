{ config, lib, pkgs, ... }:

{
  # Enable KeePassXC with Home Manager module for better configuration management
  programs.keepassxc = {
    enable = true;
    
    settings = {
      # General settings
      General = {
        ConfigVersion = 2;
        MinimizeOnClose = true;
        MinimizeOnStartup = false;
        MinimizeToTray = true;
        StartMinimized = false;
        RememberLastDatabases = true;
        RememberLastKeyFiles = true;
        OpenPreviousDatabasesOnStartup = true;
        AutoSaveAfterEveryChange = true;
        AutoSaveOnExit = true;
        BackupBeforeSave = true;
        UseAtomicSaves = true;
        SearchLimitGroup = false;
        HidePreviewPanel = false;
        HideToolbar = false;
        MovableToolbar = false;
        HidePasswords = true;
        HideUsernames = false;
        HideNotes = false;
        # Language = "system";
      };

      # Security settings - Enhanced for better security
      Security = {
        ClearClipboard = true;
        ClearClipboardTimeout = 10;  # Clear clipboard after 10 seconds
        ClearSearch = true;
        ClearSearchTimeout = 5;     # Clear search after 5 seconds
        LockDatabaseIdle = true;
        LockDatabaseIdleSeconds = 240;  # Lock after 4 minutes of inactivity
        LockDatabaseMinimize = false;
        LockDatabaseScreenLock = true;  # Lock when screen locks
        RelockAutoType = true;
        PasswordCleartext = false;
        PasswordRepeat = true;
        PasswordEmptyPlaceholders = false;
        HidePasswordPreviewPanel = true;
        PasswordsHidden = true;
        PasswordsRepeatVisible = false;
        AutoTypeAsk = true;         # Ask before auto-typing
        AutoTypeDelay = 25;         # Delay between keystrokes (ms)
        AutoTypeStartDelay = 500;   # Delay before starting auto-type
        GlobalAutoTypeKey = "Meta+Shift+A";  # Global auto-type hotkey
        GlobalAutoTypeModifiers = -1;
      };

      # GUI settings
      GUI = {
        ApplicationTheme = "auto";  # Follow system theme
        ShowTrayIcon = true;
        TrayIconAppearance = "colorful";
        MinimizeOnClose = true;
        MinimizeToTray = true;
        CheckForUpdates = false;  # Managed by Nix
        CheckForUpdatesIncludeBetas = false;
        MonospaceNotes = true;    # Use monospace font for notes
        Language = "system";      # Use system language
        DarkTrayIcon = false;
        MovableToolbar = false;
        ToolButtonStyle = 0;
      };

      # Browser integration - Enable for all supported browsers
      Browser = {
        Enabled = true;           # Enable browser integration
        ShowNotification = true;  # Show notifications for browser requests
        BestMatchOnly = false;    # Show all matches, not just best
        UnlockDatabase = true;    # Allow unlocking from browser
        MatchUrlScheme = true;    # Match URL scheme (https/http)
        SortByUsername = false;
        SupportBrowserProxy = true;
        UseCustomProxy = true;    # Use custom proxy to ensure Nix path
        CustomProxyLocation = "${pkgs.keepassxc}/bin/keepassxc-proxy";  # Nix-provided proxy
        UpdateBinaryPath = false; # Don't auto-update to prevent wrong path detection
        AllowExpiredCredentials = false;
        AlwaysAllowAccess = false;
        AlwaysAllowUpdate = false;
        HttpAuthPermission = false;
        SearchInAllDatabases = false;
        SupportKphFields = true;
        NoMigrationPrompt = false;
      };

      # Firefox-specific browser integration
      Browser_Migration = {
        Enabled = true;
      };

      Browser_Allowed = {
        Browsers = "firefox;zen";    # Allow both Firefox and Zen browser
      };

      Browser_Custom = {
        Type = "firefox";
        Enabled = true;
        Path = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isLinux "${pkgs.firefox}/bin/firefox")
          (lib.mkIf pkgs.stdenv.isDarwin "/Applications/Firefox.app/Contents/MacOS/firefox")
        ];
      };

      # Firefox-specific browser integration (also applies to Zen browser)
      Browser_Firefox = {
        Enabled = true;
        AllowExpiredCredentials = false;
        AlwaysAllowAccess = false;
        AlwaysAllowUpdate = false;
        HttpAuthPermission = false;
        NoMigrationPrompt = true;
        SearchInAllDatabases = false;
        ShowNotification = true;
        SupportBrowserProxy = true;
        UnlockDatabase = true;
        UseCustomProxy = true;    # Use custom proxy for Firefox
        CustomProxyLocation = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        UpdateBinaryPath = false; # Prevent auto-detection of wrong paths
      };

      # Zen browser integration (same as Firefox since it's Firefox-based)
      Browser_Zen = {
        Enabled = true;
        AllowExpiredCredentials = false;
        AlwaysAllowAccess = false;
        AlwaysAllowUpdate = false;
        HttpAuthPermission = false;
        NoMigrationPrompt = true;
        SearchInAllDatabases = false;
        ShowNotification = true;
        SupportBrowserProxy = true;
        UnlockDatabase = true;
        UseCustomProxy = true;    # Use custom proxy for Zen browser
        CustomProxyLocation = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        UpdateBinaryPath = false; # Prevent auto-detection of wrong paths
      };

      # Password Generator defaults - Strong passwords by default
      PasswordGenerator = {
        Length = 20;              # 20 character passwords
        SpecialChars = true;      # Include special characters
        Numbers = true;           # Include numbers
        LowerCase = true;         # Include lowercase letters
        UpperCase = true;         # Include uppercase letters
        ExcludeAlike = true;      # Exclude similar looking characters
        EnsureEvery = false;      # Don't force every character type
        EASCII = false;           # Don't use extended ASCII
        AdvancedMode = false;     # Use simple mode by default
      };

      # FdoSecrets (Linux secret service integration)
      FdoSecrets = lib.mkIf pkgs.stdenv.isLinux {
        Enabled = true;           # Enable secret service on Linux
        ShowNotification = true;  # Show notifications for secret requests
        ConfirmDeleteItem = true; # Confirm before deleting items
        ConfirmAccessItem = false; # Don't confirm for each access
        UnlockBeforeSearch = true; # Unlock database before searching
      };

      # SSH Agent integration (disabled by default, can be enabled if needed)
      SSHAgent = {
        Enabled = false;          # Enable SSH agent integration
        AuthSock = "";            # Use default SSH auth socket
        UseOpenSSH = true;        # Use OpenSSH format
      };
    };
  };

  # Manual native messaging host configuration for broader browser support
  # This ensures Zen browser and other Firefox-based browsers can communicate with KeePassXC
  # We explicitly override any auto-generated config to ensure it uses the Nix-provided proxy
  home.file = {
    # Standard Firefox/Zen browser native messaging host (for non-Flatpak browsers)
    ".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = {
      force = true;  # Override any existing file to ensure correct Nix path
      text = builtins.toJSON {
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
        allowed_extensions = [
          "keepassxc-browser@keepassxc.org"
        ];
      };
    };
    
    # Flatpak native messaging host for Zen browser (if installed via Flatpak)
    ".var/app/app.zen_browser.zen/data/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = lib.mkIf pkgs.stdenv.isLinux {
      force = true;
      text = builtins.toJSON {
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support (Flatpak)";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
        allowed_extensions = [
          "keepassxc-browser@keepassxc.org"
        ];
      };
    };
    
    # Alternative Flatpak location for Mozilla-based browsers
    ".var/app/app.zen_browser.zen/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = lib.mkIf pkgs.stdenv.isLinux {
      force = true;
      text = builtins.toJSON {
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support (Flatpak Mozilla)";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
        allowed_extensions = [
          "keepassxc-browser@keepassxc.org"
        ];
      };
    };
    
    # Also create directories to ensure they exist
    ".mozilla/native-messaging-hosts/.keep".text = "";
    ".var/app/app.zen_browser.zen/data/native-messaging-hosts/.keep".text = lib.mkIf pkgs.stdenv.isLinux "";
    ".var/app/app.zen_browser.zen/.mozilla/native-messaging-hosts/.keep".text = lib.mkIf pkgs.stdenv.isLinux "";
    
    # Create a verification script to check native messaging configuration
    ".local/bin/check-keepassxc-integration".text = ''
      #!/usr/bin/env bash
      # Script to verify KeePassXC native messaging configuration
      
      set -e
      
      echo "🔐 KeePassXC Native Messaging Configuration Check"
      echo "================================================"
      echo ""
      
      # Color codes
      GREEN='\033[0;32m'
      RED='\033[0;31m'
      YELLOW='\033[1;33m'
      NC='\033[0m' # No Color
      
      # Expected proxy path
      EXPECTED_PROXY="${pkgs.keepassxc}/bin/keepassxc-proxy"
      
      # Check if KeePassXC proxy exists
      if [ -x "$EXPECTED_PROXY" ]; then
        echo -e "✅ KeePassXC proxy found: ${GREEN}$EXPECTED_PROXY${NC}"
      else
        echo -e "❌ KeePassXC proxy not found: ${RED}$EXPECTED_PROXY${NC}"
        exit 1
      fi
      
      echo ""
      echo "Checking native messaging host configurations:"
      echo ""
      
      # Function to check a native messaging host file
      check_nm_host() {
        local file="$1"
        local description="$2"
        
        if [ -f "$file" ]; then
          echo -e "  📄 $description: ${GREEN}Found${NC}"
          local proxy_path=$(jq -r '.path' "$file" 2>/dev/null || echo "invalid")
          if [ "$proxy_path" = "$EXPECTED_PROXY" ]; then
            echo -e "      ✅ Proxy path: ${GREEN}$proxy_path${NC}"
          else
            echo -e "      ⚠️  Proxy path: ${YELLOW}$proxy_path${NC} (expected: $EXPECTED_PROXY)"
          fi
        else
          echo -e "  📄 $description: ${YELLOW}Not found${NC}"
        fi
        echo ""
      }
      
      # Check standard Firefox/Zen browser configuration
      check_nm_host "$HOME/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" \
                    "Standard Firefox/Zen browser"
      
      # Check Flatpak configurations (Linux only)
      if [ "$(uname)" = "Linux" ]; then
        check_nm_host "$HOME/.var/app/app.zen_browser.zen/data/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" \
                      "Zen browser (Flatpak data)"
        
        check_nm_host "$HOME/.var/app/app.zen_browser.zen/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" \
                      "Zen browser (Flatpak Mozilla)"
      fi
      
      echo "🎯 Configuration check complete!"
      echo ""
      echo "To test the integration:"
      echo "1. Start KeePassXC"
      echo "2. Enable browser integration in KeePassXC settings"
      echo "3. Open Zen browser and install the KeePassXC extension"
      echo "4. Try connecting the extension to KeePassXC"
    '';
    
    # Make the verification script executable
    ".local/bin/check-keepassxc-integration".executable = true;
  };

  # Platform-specific file associations
  xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
    "application/x-keepass2" = ["org.keepassxc.KeePassXC.desktop"];
    "application/x-keepassxc" = ["org.keepassxc.KeePassXC.desktop"];
  };

  # macOS-specific configurations
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
    # Set KeePassXC as default for .kdbx files
    "com.apple.LaunchServices/com.apple.launchservices.secure" = {
      LSHandlers = [
        {
          LSHandlerContentType = "org.keepass.kdb";
          LSHandlerRoleAll = "org.keepassxc.keepassxc";
        }
        {
          LSHandlerContentType = "org.keepass.kdbx";
          LSHandlerRoleAll = "org.keepassxc.keepassxc";
        }
      ];
    };
  };
} 