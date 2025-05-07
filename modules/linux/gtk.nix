{ config, lib, pkgs, ... }:

{
  # GTK configuration
  gtk = {
    enable = true;
    
    # GTK theme, icons and cursor
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-dark-gtk;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze-icons;
      size = 24;
    };
    
    # GTK3/4 settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-menu-images = true;
      gtk-enable-event-sounds = false;
      gtk-enable-input-feedback-sounds = false;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
    
    # GTK4 settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
  };
  
  # QT theme to match GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  
  # Additional cursor settings
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  
  # Install additional theme-related packages
  home.packages = with pkgs; [
    gruvbox-dark-gtk
    papirus-icon-theme
    vanilla-dmz
    adwaita-qt
    lxappearance # GTK theme switching tool
  ];
}