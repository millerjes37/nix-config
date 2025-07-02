{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Use "Command" on macOS, "Control" on Linux
  modKey = if isDarwin then "Command" else "Control";
  
  # Wrap alacritty with nixGL on Linux for proper GL support
  alacrittyPackage = if isLinux then
    (pkgs.writeShellScriptBin "alacritty" ''
      exec ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.alacritty}/bin/alacritty "$@"
    '')
  else
    pkgs.alacritty;
in
{
    # Use home-manager's built-in Alacritty module with minimal settings
  programs.alacritty = ({
    enable = true;
    package = alacrittyPackage;
    
    settings = {
      # Simple window settings
      window = {
        padding = { x = 5; y = 5; };
        decorations = if isLinux then "none" else "full";  # No decorations on Linux
        opacity = 0.95;
        dynamic_title = true;
        
        # Platform-specific window dimensions
        dimensions = { columns = 80; lines = 24; };
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
      
      # Universal color scheme via nix-colors
      colors = {
        primary = {
          background = "0x${config.colorScheme.palette.base00}";
          foreground = "0x${config.colorScheme.palette.base05}";
        };
        cursor = {
          text = "0x${config.colorScheme.palette.base00}";
          cursor = "0x${config.colorScheme.palette.base05}";
        };
        vi_mode_cursor = {
          text = "0x${config.colorScheme.palette.base00}";
          cursor = "0x${config.colorScheme.palette.base09}";
        };
        search = {
          matches = {
            foreground = "0x${config.colorScheme.palette.base00}";
            background = "0x${config.colorScheme.palette.base0A}";
          };
          focused_match = {
            foreground = "0x${config.colorScheme.palette.base00}";
            background = "0x${config.colorScheme.palette.base0B}";
          };
        };
        hints = {
          start = {
            foreground = "0x${config.colorScheme.palette.base00}";
            background = "0x${config.colorScheme.palette.base0A}";
          };
          end = {
            foreground = "0x${config.colorScheme.palette.base00}";
            background = "0x${config.colorScheme.palette.base0D}";
          };
        };
        selection = {
          text = "0x${config.colorScheme.palette.base05}";
          background = "0x${config.colorScheme.palette.base02}";
        };
        normal = {
          black = "0x${config.colorScheme.palette.base00}";
          red = "0x${config.colorScheme.palette.base08}";
          green = "0x${config.colorScheme.palette.base0B}";
          yellow = "0x${config.colorScheme.palette.base0A}";
          blue = "0x${config.colorScheme.palette.base0D}";
          magenta = "0x${config.colorScheme.palette.base0E}";
          cyan = "0x${config.colorScheme.palette.base0C}";
          white = "0x${config.colorScheme.palette.base05}";
        };
        bright = {
          black = "0x${config.colorScheme.palette.base03}";
          red = "0x${config.colorScheme.palette.base08}";
          green = "0x${config.colorScheme.palette.base0B}";
          yellow = "0x${config.colorScheme.palette.base0A}";
          blue = "0x${config.colorScheme.palette.base0D}";
          magenta = "0x${config.colorScheme.palette.base0E}";
          cyan = "0x${config.colorScheme.palette.base0C}";
          white = "0x${config.colorScheme.palette.base07}";
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
  });
  
  # Install fonts for the terminal (ensure they exist)
  home.packages = with pkgs; (
    lib.optionals isDarwin [ meslo-lgs-nf ] ++
    lib.optionals isLinux [ dejavu_fonts ]
  );
}