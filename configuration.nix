{ config, pkgs, ... }:

{
  # Window manager services - managed by manual scripts for reliability
  services.yabai.enable = false; # Managed externally for better stability
  services.skhd.enable = false;  # Managed externally for better stability

  # Install system-wide packages
  environment.systemPackages = with pkgs; [
    alacritty  # Terminal emulator
    jq         # Used in the terminal launch script
    yabai      # Tiling Window Manager
];

  # Enable Homebrew integration
  nix-homebrew.enable = true;
}
