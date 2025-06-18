{ pkgs, ... }:

let
  # Pull all nixGL wrappers (Intel, Mesa, Nvidia, etc.)
  nixGL = pkgs.nixgl.auto;

  # Replace the plain alacritty binary with a wrapper that injects nixGL.
  myAlacritty = pkgs.writeShellScriptBin "alacritty" ''
    #!/usr/bin/env bash
    exec ${nixGL}/bin/nixGLIntel ${pkgs.alacritty}/bin/alacritty "$@"
  '';
in
{
  # Make the wrappers available on the system.
  home.packages = [
    nixGL
    myAlacritty
  ];
} 