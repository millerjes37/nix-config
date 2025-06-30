{ config, lib, pkgs, extraImports ? [], ... }:

# This is the main home-manager configuration file.
# It's used to define user-specific packages, dotfiles, and services.
# - `config`: Provides access to the configuration options defined in modules.
# - `lib`: Provides helper functions from Nixpkgs.
# - `pkgs`: Provides access to the Nix Packages collection.
# - `extraImports`: A list of additional modules passed from the flake,
#   used here to import platform-specific configurations (macOS or Linux).

let
  # `isDarwin`: A boolean flag that is true if the current system is macOS.
  isDarwin = pkgs.stdenv.isDarwin;
  # `isLinux`: A boolean flag that is true if the current system is Linux.
  isLinux = pkgs.stdenv.isLinux;
  
  # `platformName`: A string identifying the current platform ("darwin" or "linux").
  # This can be useful for conditional configurations within this file or imported modules,
  # though `isDarwin` and `isLinux` are often used directly.
  platformName = if isDarwin then "darwin" else "linux";
in
{
  # `imports`: Specifies a list of other Nix files (modules) to be included.
  # This allows for a modular configuration.
  # - `./modules/common/default.nix`: Imports shared configurations applicable to both macOS and Linux.
  # - `++ extraImports`: Appends platform-specific modules (e.g., from `./modules/darwin/default.nix`
  #   or `./modules/linux/default.nix`) that were passed in via the `flake.nix` `mkHomeConfig` function.
  imports = [ 
    ./modules/common/default.nix  # Common modules for all platforms
    ./applications/common/default.nix  # Applications (terminal, utilities, editors, etc.)
  ] ++ extraImports; # Platform-specific modules (macOS or Linux)
  
  # `fonts.fontconfig.enable`: Enables fontconfig, a library for font customization and discovery.
  # This ensures that fonts installed by home-manager are correctly recognized by applications.
  fonts.fontconfig.enable = true;

  # `home.stateVersion`: Specifies the version of home-manager to which this configuration is compatible.
  # It's important to update this when migrating to newer home-manager releases if breaking changes occur.
  # See home-manager documentation for details on state versions.
  home.stateVersion = "25.05";  
  
  # `nixpkgs.config.allowUnfree`: Allows the installation of packages that have unfree licenses.
  # Set to `true` to enable installation of proprietary software if needed.
  nixpkgs.config.allowUnfree = true;
  
  # `programs`: A common namespace for configuring various applications managed by home-manager.
  programs = {
    # `home-manager.enable`: Enables the home-manager program itself, allowing it to manage your configuration.
    # This is typically always true in a home-manager setup.
    home-manager.enable = true;
  };

  # Disable Home Manager news notifications
  news.display = "silent";

  # `xsession`: Configures the X session for Linux desktop environments.
  # `lib.mkIf isLinux { ... }`: This block is only applied if the system is Linux (`isLinux` is true).
  xsession = lib.mkIf isLinux {
    # `enable = true;`: Enables home-manager's X session management.
    enable = true;
    # `numlock.enable = true;`: Ensures NumLock is enabled when the X session starts.
    numlock.enable = true;
  };

  # `launchd`: Configures launchd, the service management framework on macOS.
  # `lib.mkIf isDarwin { ... }`: This block is only applied if the system is macOS (`isDarwin` is true).
  launchd = lib.mkIf isDarwin {
    # `enable = true;`: Enables home-manager's integration with launchd for managing user agents and daemons.
    enable = true;
  };

  # `home.activation`: Defines actions to be run when the home-manager generation is activated (e.g., after `home-manager switch`).
  # These are often used for tasks that need to happen outside of normal package installation or file linking.
  home.activation = {
    # `reloadSystemdCustom`: A custom activation script specific to Linux systems using systemd.
    # `lib.mkIf isLinux (...)`: This script only runs on Linux.
    # `lib.hm.dag.entryAfter ["writeBoundary"]`: Ensures this script runs after home-manager has finished writing files.
    # The script itself checks if `systemctl` is available and, if so, prints a message
    # indicating that systemd user services might need reloading.
    # In a more complete setup, it might actually run `systemctl --user daemon-reload`.
    reloadSystemdCustom = lib.mkIf isLinux (lib.hm.dag.entryAfter ["writeBoundary"] ''
      if command -v systemctl >/dev/null; then
        echo "Reloading systemd user services..."
        # Consider adding: systemctl --user daemon-reload
        # Consider adding: systemctl --user restart some.service (if you have user services managed by home-manager)
      fi
    '');
  };
}