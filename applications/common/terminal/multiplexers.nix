{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij              # Terminal multiplexer (Rust)
    # tmux can be added here if needed
    # screen can be added here if needed
  ];

  # Configure zellij if needed
  # programs.zellij = {
  #   enable = true;
  #   settings = {
  #     # Custom zellij configuration
  #   };
  # };
} 