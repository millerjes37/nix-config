{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./zsh.nix
    ./starship.nix
    ./multiplexers.nix
    ./zellij.nix
  ];
} 