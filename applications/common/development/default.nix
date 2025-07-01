{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./languages.nix
    ./rust.nix
    ./ai-tools.nix
    ./claude-tools.nix
    ./containers.nix
    ./databases.nix
  ];

  home.packages = with pkgs; [
    # Build tools and utilities
    just                # Command runner
    dprint              # Code formatter (Rust)
  ];

  # Enable direnv for project-specific environments
  programs.direnv.enable = true;
} 