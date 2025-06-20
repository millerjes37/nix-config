{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Encryption tools
    age                 # File encryption (Go)
    fx                  # JSON viewer (JS)
  ];
} 