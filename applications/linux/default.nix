{ config, lib, pkgs, ... }:

{
  imports = [
    ./flatpak.nix
    ./appimage.nix
    ./gaming.nix
    ./linux-utilities.nix
  ];

  # Linux-specific packages
  home.packages = with pkgs; [
    # Linux utilities and tools
    # Add Linux-specific packages here
  ];
} 