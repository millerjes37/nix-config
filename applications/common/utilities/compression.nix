{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # File compression
    ouch                # Compression tool
    p7zip               # 7zip
    unzip
    zstd                # High-performance compression
  ];
} 