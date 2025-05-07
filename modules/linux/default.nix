{ config, lib, pkgs, ... }:

{
  # Import all Linux-specific modules
  imports = [
    ./i3.nix           # Window manager
    # ./gtk.nix        # GTK theming - temporarily disabled
    ./rofi.nix         # Application launcher
    ./linux-apps.nix   # Linux-specific applications
  ];
  
  # Common Linux-specific packages
  home.packages = with pkgs; [
    # GUI tools
    firefox
    keepassxc
    libreoffice
    discord
    
    # System utilities
    pavucontrol      # Audio control
    blueman          # Bluetooth manager
    networkmanager   # Network management
    
    # Window management tools
    xclip            # Clipboard tool
    xdotool          # X11 automation
    xorg.xev         # X event viewer
    dunst            # Notification daemon
  ];
  
  # Enable XDG desktop integration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };
  };
}