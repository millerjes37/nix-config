{ pkgs, ... }:

{
  imports = [
    ../common/keybindings.nix  # Shared keybindings
    ./nixos.nix
    ./home.nix
    ./hyprland.nix
    ./flatpak.nix
  ];
}
