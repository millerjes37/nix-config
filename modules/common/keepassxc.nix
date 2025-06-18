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
        UseCustomProxy = false;
        CustomProxyLocation = "";
        UpdateBinaryPath = true;
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
        Browsers = "firefox";    # Explicitly allow Firefox
      };

      Browser_Custom = {
        Type = "firefox";
        Enabled = true;
        Path = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isLinux "${pkgs.firefox}/bin/firefox")
          (lib.mkIf pkgs.stdenv.isDarwin "/Applications/Firefox.app/Contents/MacOS/firefox")
        ];
      };

      # Additional browser integration settings
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
        UseCustomProxy = false;
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