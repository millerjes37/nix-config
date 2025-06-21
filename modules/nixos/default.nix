{ pkgs, ... }:

{
  imports = [
    ./nixos.nix
    ./hyprland.nix
    ./flatpak.nix
  ];
}
