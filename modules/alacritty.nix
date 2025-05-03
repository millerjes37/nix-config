{ config, lib, pkgs, ... }:

{
  # Use home-manager's built-in Alacritty module but with our custom settings
  programs.alacritty = {
    enable = true;
    
    # Fixed settings to match current format of home-manager
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        size = 20;
      };
      
      window = {
        opacity = 0.95;
      };
      
      colors = {
        # Enhanced Gruvbox dark theme with more teal/cyan emphasis
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };
        normal = {
          black = "#282828";
          red = "#cc241d";
          green = "#8ec07c";  # More teal-green
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";   # Standard gruvbox cyan
          white = "#a89984";
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#8ec07c";  # Brighter teal-green
          yellow = "#fabd2f";
          blue = "#83a598";   # Blueish-teal
          magenta = "#d3869b";
          cyan = "#26a69a";   # More vibrant teal
          white = "#ebdbb2";
        };
        cursor = {
          text = "#282828";
          cursor = "#26a69a";  # Teal cursor
        };
        selection = {
          text = "#ebdbb2";
          background = "#2c3a41";  # Dark teal background
        };
      };
      
      keyboard = {
        bindings = [
          { key = "C"; mods = "Command"; action = "Copy"; }
          { key = "V"; mods = "Command"; action = "Paste"; }
          { key = "N"; mods = "Command"; action = "SpawnNewInstance"; }
          { key = "Q"; mods = "Command"; action = "Quit"; }
          { key = "F"; mods = "Command|Control"; action = "ToggleFullscreen"; }
          { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
          { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
          { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        ];
      };
    };
  };
}
