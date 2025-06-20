{ config, lib, pkgs, ... }:

{
  imports = [
    ./yabai.nix
    ./skhd.nix
  ];
} 