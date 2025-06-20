{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Network tools
    curl
    wget
    xh                  # HTTP client
    dog                 # DNS lookup (Rust)
    mtr                 # Better traceroute
    nmap                # Network discovery
    trippy              # Ping/traceroute TUI (Rust)
    gping               # Graphical ping (Rust)
    feroxbuster         # Web directory brute-forcer (Rust)
    
    # File transfer
    rsync
    miniserve           # Simple HTTP server
  ];
} 