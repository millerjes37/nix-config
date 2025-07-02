{ pkgs, lib, ... }:

let
  # Use nixGLIntel directly and avoid auto-detection that may cause deprecation warnings
  nixGLIntel = pkgs.nixgl.nixGLIntel;
in
{
  # Only enable nixGL wrappers on Linux systems
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Make the wrappers available on the system.
    home.packages = [
      nixGLIntel
    ];
    
    # Environment variables to help with GL applications
    home.sessionVariables = {
      # Help applications find the correct GL library
      NIXGL_PREFIX = "${nixGLIntel}/bin/nixGLIntel";
    };
  };
} 