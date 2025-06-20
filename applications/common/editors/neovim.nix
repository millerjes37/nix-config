{ config, lib, pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
} 