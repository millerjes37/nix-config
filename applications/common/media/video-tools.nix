{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Video tools
    # ffmpeg
    # obs-studio
    # kdenlive
    # Add video tools here as needed
  ];
} 