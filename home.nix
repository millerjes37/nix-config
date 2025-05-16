{ config, lib, pkgs, extraImports ? [], ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Platform identification
  platformName = if isDarwin then "darwin" else "linux";
in
{
  # Import all modules directly - platform-specific modules come via extraImports
  imports = [ 
    ./modules/common/default.nix  # Add direct import to common modules
  ] ++ extraImports;
  
  # Enable font discovery for all platforms
  fonts.fontconfig.enable = true;

  # Home-manager settings
  home.stateVersion = "25.05";  
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Configure program defaults that work on both platforms
  programs = {
    # Enable home-manager
    home-manager.enable = true;
    
    # Configure browser - different for each platform
    firefox = {
      enable = isLinux;  # Only enable on Linux, use App Store on macOS
    };
  };

  # On Linux, enable X session and set proper keyboard configuration
  xsession = lib.mkIf isLinux {
    enable = true;
    numlock.enable = true;
  };

  # On macOS, enable launchd
  launchd = lib.mkIf isDarwin {
    enable = true;
  };

  # Add hooks for post-build actions based on platform
  home.activation = {
    reloadSystemdCustom = lib.mkIf isLinux (lib.hm.dag.entryAfter ["writeBoundary"] ''
      if command -v systemctl >/dev/null; then
        echo "Reloading systemd user services..."
      fi
    '');
  };
}