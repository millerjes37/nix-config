# Cursor (AI Code Editor) configuration for macOS
{ config, lib, pkgs, ... }:

{
  # Install Cursor on macOS - no special sandbox configuration needed
  home.packages = with pkgs; [
    code-cursor
  ];

  # Create desktop entries (Applications folder shortcuts) for macOS
  home.file."Applications/Cursor.app" = lib.mkIf pkgs.stdenv.isDarwin {
    source = "${pkgs.code-cursor}/Applications/Cursor.app";
    recursive = true;
  };

  # Set file associations for common development files on macOS
  targets.darwin.defaults = {
    "com.todesktop.230313mzl4w4u92" = {
      # Cursor's bundle identifier - these settings would be app-specific
      NSNavLastRootDirectory = "~/Projects";
    };
  };
} 