{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Database tools
    # postgresql
    # mysql
    # sqlite
    # redis
    # Add database tools here as needed
  ];
} 