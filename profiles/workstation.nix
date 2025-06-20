{ config, lib, pkgs, ... }:

{
  # Full workstation profile with all development tools
  imports = [
    ../applications/common/default.nix
  ];

  # Development-focused configuration
  home.packages = with pkgs; [
    # Additional workstation tools
    # docker-compose
    # kubectl
    # terraform
  ];
} 