{ config, lib, pkgs, inputs, ... }:

{
  # Import nix-colors home-manager module
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  # Color scheme options for light browns, tans, and dark backgrounds:
  # Try these by uncommenting one at a time:
  
  # Atelier Cave - Dark purple/brown cave theme
  # colorScheme = inputs.nix-colors.colorSchemes.atelier-cave;
  
  # Atelier Dune - Sandy dune colors with browns and tans
  # colorScheme = inputs.nix-colors.colorSchemes.atelier-dune;
  
  # Atelier Heath - Muted earth tones with browns
  # colorScheme = inputs.nix-colors.colorSchemes.atelier-heath;
  
  # Gruvbox Dark Medium - Warmer browns (recommended for you!)
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  
  # Gruvbox Dark Soft - Softer browns and tans
  # colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-soft;
  
  # Ir Black - Dark with brown/orange accents
  # colorScheme = inputs.nix-colors.colorSchemes.ir-black;

  # Export color scheme for easy access in other modules
  # This allows other modules to use config.colorScheme.palette.baseXX
} 