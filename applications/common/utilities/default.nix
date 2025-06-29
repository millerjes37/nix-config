{ config, lib, pkgs, ... }:

{
  imports = [
    ./cli-tools.nix
    ./system-monitoring.nix
    ./network-tools.nix
    ./compression.nix
    ./file-managers.nix
    ./syncthing.nix
  ];
} 