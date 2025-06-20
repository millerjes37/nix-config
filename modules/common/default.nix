{ config, lib, pkgs, ... }:

{
  # Import system configuration modules only
  imports = [
    ./fonts.nix
    ./xdg.nix
    ./locale.nix
    ./theming.nix
  ];

  # Essential system configuration
  home.stateVersion = "23.11";
  
  # Enable common programs that are part of the system configuration
  programs = {
    home-manager.enable = true;
  };
} 