{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # System monitoring
    btop                # Resource monitor
    glances             # System monitor (Python)
    bandwhich           # Network bandwidth monitor (Rust)
  ];
} 