{ config, lib, pkgs, ... }:

{
  imports = [
    ./aerospace.nix
  ];
  
  # Enable our custom aerospace configuration
  programs.aerospace-custom.enable = true;
} 