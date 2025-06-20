{ config, lib, pkgs, ... }:

{
  imports = [
    ./gimp.nix
    ./workflows.nix
    ./audio-tools.nix
    ./video-tools.nix
  ];
} 