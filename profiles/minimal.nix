{ config, lib, pkgs, ... }:

{
  # Minimal profile with essential tools only
  imports = [
    ../applications/common/terminal/default.nix
    ../applications/common/utilities/cli-tools.nix
    ../applications/common/development/git.nix
    ../applications/common/editors/neovim.nix
  ];

  # Minimal package set
  home.packages = with pkgs; [
    # Only essential packages
    curl
    wget
    git
  ];
} 