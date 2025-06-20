{ config, lib, pkgs, ... }:

{
  # Full workstation profile with all development tools
  imports = [
    ../applications/common/default.nix
  ];

  # Enable all editors (user can comment out what they don't want)
  applications.common.editors = {
    neovim.enable = true;
    # nixvim.enable = true;    # Advanced Neovim config
    # helix.enable = true;     # Helix editor
    # emacs.enable = true;     # Emacs editor
  };

  # Development-focused configuration
  home.packages = with pkgs; [
    # Additional workstation tools
    # docker-compose
    # kubectl
    # terraform
  ];
} 