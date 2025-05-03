{ config, lib, pkgs, ... }:

{
  # Use home-manager's built-in Alacritty module but with our custom settings
  programs.alacritty = {
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        size = 12;
      };
      
      window = {
        opacity = 1.0;
      };
      
      colors = {
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };
        normal = {
          black = "#282828";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          purple = "#b16286";
          aqua = "#689d6a";
          gray = "#a89984";
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          purple = "#d3869b";
          aqua = "#8ec07c";
          gray = "#ebdbb2";
        };
        cursor = {
          text = "#282828";
          cursor = "#b8bb26";
        };
        selection = {
          text = "#ebdbb2";
          background = "#504945";
        };
      };
      
      key_bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
      ];
    };
  };
}
