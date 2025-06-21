{ config, lib, pkgs, ... }:

{
  # Minimal profile for testing
  home.packages = with pkgs; [
    git
    curl
  ];
  
  programs.bash.enable = true;
  
  # Basic configuration
  home.stateVersion = "23.11";
} 