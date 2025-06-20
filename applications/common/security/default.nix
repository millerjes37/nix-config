{ config, lib, pkgs, ... }:

{
  imports = [
    ./keepassxc.nix
    ./encryption.nix
    ./password-managers.nix
  ];
} 