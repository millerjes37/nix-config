{ config, pkgs, ... }:

{
  # NixOS configuration options go here
  system.stateVersion = "23.11"; # Or your desired version

  users.users.jules = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # For sudo access
    shell = pkgs.zsh;
    home = "/home/jackson";
    initialPassword = "JEM"; # Set an initial password
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable XDG Desktop Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
