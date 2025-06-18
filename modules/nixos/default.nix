{ pkgs, ... }:

{
  imports = [
    ./nixos.nix
    ./home.nix
    ./hyprland.nix
    ./flatpak.nix
  ];
}
