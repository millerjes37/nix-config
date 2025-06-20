{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Audio tools
    # audacity
    # ardour
    # ffmpeg
    # Add audio tools here as needed
  ];
} 