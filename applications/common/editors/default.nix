{ config, lib, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./helix.nix      # Helix editor - now enabled!
    # Uncomment the editors you want to enable
    # ./nixvim.nix     # Advanced Neovim config via nixvim
    # ./emacs.nix      # Emacs editor
  ];
} 