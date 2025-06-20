{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Container tools
    # docker
    # podman
    # docker-compose
    # kubectl
    # Add container tools here as needed
  ];
} 