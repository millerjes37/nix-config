{ config, lib, pkgs, ... }:

{
  imports = [
    ./aerospace.nix
  ];
  
  # Enable aerospace instead of yabai and skhd
  programs.aerospace.enable = true;
} 