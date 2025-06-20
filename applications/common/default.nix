{ config, lib, pkgs, ... }:

{
  imports = [
    ./terminal/default.nix
    ./utilities/default.nix
    ./development/default.nix
    ./editors/default.nix
    ./security/default.nix
    ./media/default.nix
  ];

  # Common home-manager settings
  programs.home-manager.enable = true;

  # Create directory for common shell scripts
  home.file.".local/bin" = lib.mkIf (builtins.pathExists ../../scripts/common) {
    source = ../../scripts/common;
  };
} 