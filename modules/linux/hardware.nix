{ config, lib, pkgs, ... }:

{
  # Linux-specific hardware configuration and services
  
  # Hardware-related packages
  home.packages = with pkgs; [
    # System utilities
    pavucontrol      # Audio control
    blueman          # Bluetooth manager
    
    # X11 utilities
    xclip            # Clipboard tool
    xdotool          # X11 automation
    xorg.xev         # X event viewer
    
    # Hardware monitoring
    # lm_sensors      # Hardware sensors
    # smartmontools   # Disk monitoring
  ];

  # Hardware-specific services
  services = {
    # Notification daemon
    dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "300x5-30+20";
          transparency = 10;
          frame_color = "#eceff1";
          font = "Droid Sans 9";
        };
        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };
      };
    };
  };
} 