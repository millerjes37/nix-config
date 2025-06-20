{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # AppImage support
    appimage-run      # Run AppImages on NixOS
    # appimagekit      # AppImage creation tools
  ];

  # Create AppImage directory and set up launcher
  home.file.".local/share/applications/appimage-launcher.desktop" = lib.mkIf pkgs.stdenv.isLinux {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=AppImage Launcher
      Exec=${pkgs.appimage-run}/bin/appimage-run %F
      Icon=application-x-executable
      MimeType=application/x-appimage;
      NoDisplay=true
    '';
  };
} 