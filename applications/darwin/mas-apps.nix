{ config, lib, pkgs, ... }:

{
  # Mac App Store applications
  home.packages = with pkgs; [
    mas  # Mac App Store CLI (already included in darwin/default.nix)
  ];

  # Example MAS app installations (uncomment and modify as needed)
  # Note: You'll need to find the app IDs using `mas search <app-name>`
  # 
  # home.activation.installMasApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   ${pkgs.mas}/bin/mas install 497799835  # Xcode
  #   ${pkgs.mas}/bin/mas install 1295203466 # Microsoft Remote Desktop
  #   ${pkgs.mas}/bin/mas install 1429033973 # RunCat
  # '';
} 