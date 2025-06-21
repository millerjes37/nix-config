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
      # Add Homebrew casks here for macOS applications not available in Nix
      # Examples: "discord", "slack", "notion", etc.
    ];

    # `masApps`: A dictionary of Mac App Store applications to install.
    # The key is the name of the app, and the value is the App Store ID.
    masApps = {
      # Add Mac App Store applications here
      # Example: "Xcode" = 497799835;
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
