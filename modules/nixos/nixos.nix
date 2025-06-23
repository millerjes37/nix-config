{ config, pkgs, ... }:

{
  # NixOS configuration options go here
  system.stateVersion = "23.11"; # Or your desired version

  users.users.jackson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # For sudo access
    shell = pkgs.zsh;
    home = "/home/jackson";
    initialPassword = "JEM"; # Set an initial password
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
