{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Use "Command" on macOS, "Control" on Linux
  modKey = if isDarwin then "Command" else "Control";
  
  # Common keyboard bindings that work on both platforms
  commonBindings = [
    { key = "C"; mods = modKey; action = "Copy"; }
    { key = "V"; mods = modKey; action = "Paste"; }
    { key = "N"; mods = modKey; action = "SpawnNewInstance"; }
    { key = "Q"; mods = modKey; action = "Quit"; }
    { key = "F"; mods = "${modKey}|Alt"; action = "ToggleFullscreen"; }
    { key = "Key0"; mods = modKey; action = "ResetFontSize"; }
    { key = "Equals"; mods = modKey; action = "IncreaseFontSize"; }
    { key = "Minus"; mods = modKey; action = "DecreaseFontSize"; }
  ];
  
  # Platform-specific bindings
  macBindings = [];
  linuxBindings = [
    # Add Linux-specific shortcuts here if needed
  ];
in
{
  # Use home-manager's built-in Alacritty module but with our custom settings
  programs.alacritty = {
    enable = true;
    
    # Fixed settings to match current format of home-manager
    settings = {
      font = {
        normal = {
          # Use platform-specific fonts
          family = if isDarwin then "FiraCode Nerd Font" else "FiraMono Nerd Font Mono";
          style = "Regular";
        };
        # Use a slightly smaller font on Linux
        size = if isDarwin then 20 else 12;
      };
      
      window = {
        opacity = 0.95;
        # Ensure proper window size on Linux
        dimensions = if isLinux then {
          columns = 120;
          lines = 35;
        } else null;
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
        bindings = commonBindings 
          ++ (if isDarwin then macBindings else linuxBindings);
      };
    };
  };
}
