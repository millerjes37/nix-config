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
          magenta = "#b16286";  # purple → magenta
          cyan = "#689d6a";     # aqua → cyan
          white = "#a89984";    # gray → white
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          magenta = "#d3869b";  # purple → magenta
          cyan = "#8ec07c";     # aqua → cyan
          white = "#ebdbb2";    # gray → white
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
