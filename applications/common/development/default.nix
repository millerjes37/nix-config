{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./languages.nix
    ./containers.nix
    ./databases.nix
  ];

  home.packages = with pkgs; [
    # Build tools and utilities
    just                # Command runner
    dprint              # Code formatter (Rust)
    cargo               # Rust package manager
  ];

  # Enable direnv for project-specific environments
  programs.direnv.enable = true;
} 