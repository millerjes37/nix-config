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
        dimensions = if isLinux then {
          columns = 110;
          lines = 30;
        } else null;
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
      
      # Simple dark theme (terminal-centric)
      colors = {
        primary = {
          background = "#1d1f21";
          foreground = "#c5c8c6";
        };
        cursor = {
          text = "#1d1f21";
          cursor = "#c5c8c6";
        };
        normal = {
          black = "#1d1f21";
          red = "#cc6666";
          green = "#b5bd68";
          yellow = "#f0c674";
          blue = "#81a2be";
          magenta = "#b294bb";
          cyan = "#8abeb7";
          white = "#c5c8c6";
        };
        bright = {
          black = "#666666";
          red = "#d54e53";
          green = "#b9ca4a";
          yellow = "#e7c547";
          blue = "#7aa6da";
          magenta = "#c397d8";
          cyan = "#70c0b1";
          white = "#eaeaea";
        };
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