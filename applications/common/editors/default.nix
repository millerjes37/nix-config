{ config, lib, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    # Uncomment the editors you want to enable
    # ./nixvim.nix     # Advanced Neovim config via nixvim
    # ./helix.nix      # Helix editor
    # ./emacs.nix      # Emacs editor
  ];
} 