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


  # ---------------------------------------------------------------------------
  # Minimal disk configuration (placeholder)
  # These values make the flake evaluation pass.  Adjust for real hardware.
  # ---------------------------------------------------------------------------
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";  # Placeholder device
    fsType = "ext4";
  };

  # Basic boot loader configuration (required by NixOS assertions)
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];  # Placeholder; replace with actual disk
  };
}
