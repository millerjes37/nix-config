{ config, lib, pkgs, ... }:

{
  # XDG Base Directory configuration
  xdg = {
    enable = true;
    
    # Configure XDG directories
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
    
    # Set up MIME types and default applications (Linux only)
    mimeApps.enable = pkgs.stdenv.isLinux;
  };
} 