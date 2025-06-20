{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      # Add custom starship configuration here
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
} 