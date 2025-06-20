{ config, lib, pkgs, ... }:

{
  # Media production profile focused on creative workflows
  imports = [
    ../applications/common/terminal/default.nix
    ../applications/common/utilities/default.nix
    ../applications/common/development/git.nix
    ../applications/common/editors/neovim.nix
    ../applications/common/media/default.nix
  ];

  # Media production focused packages
  home.packages = with pkgs; [
    # Audio production
    # audacity
    # ardour
    # reaper
    
    # Video production
    # obs-studio
    # kdenlive
    # blender
    
    # Graphics
    # inkscape
    # krita
    # darktable
    
    # Media utilities
    ffmpeg
    imagemagick
    # exiftool
  ];
} 