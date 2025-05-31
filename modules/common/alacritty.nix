{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Use "Command" on macOS, "Control" on Linux
  modKey = if isDarwin then "Command" else "Control";
in
{
  # Use home-manager's built-in Alacritty module with minimal settings
  programs.alacritty = {
    enable = true;
    
    settings = {
      # Simple window settings
      window = {
        padding = { x = 5; y = 5; };
        decorations = "full";
        opacity = 0.95;
        dynamic_title = true;
        
        # Platform-specific window dimensions
        dimensions = { columns = 80; lines = 24 }
      };
      
      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      # Font settings
      font = {
        normal = {
          # Use platform-specific fonts that work well in terminals
          family = if isDarwin then "MesloLGS NF" else "DejaVu Sans Mono";
          style = "Regular";
        };
        bold = {
          family = if isDarwin then "MesloLGS NF" else "DejaVu Sans Mono";
          style = "Bold";
        };
        italic = {
          family = if isDarwin then "MesloLGS NF" else "DejaVu Sans Mono";
          style = "Italic";
        };
        # Platform-specific font size
        size = if isDarwin then 16.0 else 11.0;
      };
      
      # Cursor settings
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        unfocused_hollow = true;
        thickness = 0.2;
      };
      
      # Gruvbox Dark theme
      colors = {
        primary = {
          background = "0x1d2021";
          foreground = "0xd4be98";
        };
        cursor = {
          text = "0x1d2021";
          cursor = "0xec5d2a";
        };
        vi_mode_cursor = {
          text = "0x1d2021";
          cursor = "0xec5d2a";
        };
        search = {
          matches = {
            foreground = "0x1d2021";
            background = "0x7daea3"; # blue
          };
          focused_match = {
            foreground = "0x1d2021";
            background = "0xa9b665"; # green
          };
        };
        hints = {
          start = {
            foreground = "0x1d2021";
            background = "0xd8a657"; # yellow
          };
          end = {
            foreground = "0x1d2021";
            background = "0x7daea3"; # blue
          };
        };
        selection = {
          text = "0xd4be98";
          background = "0x32302f";
        };
        normal = {
          black = "0x32302f";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
        bright = {
          black = "0x32302f";
          red = "0xea6962";
          green = "0xa9b665";
          yellow = "0xd8a657";
          blue = "0x7daea3";
          magenta = "0xd3869b";
          cyan = "0x89b482";
          white = "0xd4be98";
        };
        # Gruvbox theme doesn't typically use indexed_colors
      };
      
      # Essential key bindings
      keyboard = {
        bindings = [
          # Copy/paste
          { key = "C"; mods = modKey; action = "Copy"; }
          { key = "V"; mods = modKey; action = "Paste"; }
          # Window management
          { key = "N"; mods = modKey; action = "SpawnNewInstance"; }
          { key = "Q"; mods = "${modKey}|Shift"; action = "Quit"; }
          { key = "F"; mods = "${modKey}|Control"; action = "ToggleFullscreen"; }
          # Font size
          { key = "Key0"; mods = modKey; action = "ResetFontSize"; }
          { key = "Equals"; mods = modKey; action = "IncreaseFontSize"; }
          { key = "Minus"; mods = modKey; action = "DecreaseFontSize"; }
        ];
      };
    };
  };
  
  # Install fonts for the terminal (ensure they exist)
  home.packages = with pkgs; [
    # Terminal fonts
    (if isDarwin then meslo-lgs-nf else dejavu_fonts)
  ];
}