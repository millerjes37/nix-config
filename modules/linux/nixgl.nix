{ pkgs, ... }:

let
  # Use nixGLIntel directly to avoid auto-detection that uses builtins.currentTime
  nixGLIntel = pkgs.nixgl.nixGLIntel;

  # Replace the plain alacritty binary with a wrapper that injects nixGL.
  myAlacritty = pkgs.writeShellScriptBin "alacritty" ''
    #!/usr/bin/env bash
    exec ${nixGLIntel}/bin/nixGLIntel ${pkgs.alacritty}/bin/alacritty "$@"
  '';
in
{
  # Make the wrappers available on the system.
  home.packages = [
    nixGLIntel
    myAlacritty
  ];
} 