{ config, lib, pkgs, inputs, ... }:

{
  # Import nix-colors home-manager module
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  # Set default color scheme to Gruvbox Dark (which matches your current terminal theme)
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # Export color scheme for easy access in other modules
  # This allows other modules to use config.colorScheme.palette.baseXX
} 