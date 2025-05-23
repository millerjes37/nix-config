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
      
      # Catppuccin Mocha theme
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          # dim_foreground = "#7f849c"; # Not a standard alacritty primary option
          # bright_foreground = "#cdd6f4"; # Not a standard alacritty primary option
        };
        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };
        vi_mode_cursor = {
          text = "#1e1e2e";
          cursor = "#b4befe";
        };
        search = {
          matches = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
          focused_match = {
            foreground = "#1e1e2e";
            background = "#a6e3a1";
          };
        };
        footer_bar = { # This might not be a standard Alacritty option, will check.
                       # Update: Alacritty docs confirm 'footer_bar' is valid.
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };
        hints = {
          start = {
            foreground = "#1e1e2e";
            background = "#f9e2af";
          };
          end = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
        };
        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
        # dim_foreground and bright_foreground from the TOML root are general palette colors.
        # Alacritty also has top-level `dim` and `bright` sections for *all* dim/bright colors if needed,
        # but Catppuccin provides them per color (normal.black, bright.black etc), which is standard.
        # The specific `dim_foreground` from the TOML root was "#7f849c".
        # If needed, one could set `colors.dim.foreground = "#7f849c";` but this is not standard.
        # The TOML also had a root `bright_foreground = "#cdd6f4"`, which is the same as primary.foreground.

        indexed_colors = [
          { index = 16; color = "#fab387"; }
          { index = 17; color = "#f5e0dc"; }
        ];
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