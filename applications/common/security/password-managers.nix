{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Additional password managers
    # bitwarden
    # 1password
    # pass
    # Add password manager tools here as needed
  ];
} 