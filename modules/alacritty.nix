{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.alacritty;
in

{
  options.programs.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator";
    font = mkOption {
      type = types.str;
      default = "FiraCode Nerd Font";
      description = "Font family to use in Alacritty (must support Nerd Fonts).";
    };
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for Alacritty.";
    };
    opacity = mkOption {
      type = types.float;
      default = 1.0;
      description = "Background opacity for Alacritty (0.0 to 1.0).";
    };
    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = {
        "ctrl+shift+c" = "copy";
        "ctrl+shift+v" = "paste";
      };
      description = "Custom keybindings for Alacritty.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.alacritty ];

    xdg.configFile."alacritty/alacritty.toml" = {
      text = ''
        [font]
        normal = { family = "${cfg.font}", style = "Regular" }
        size = ${toString cfg.fontSize}

        [window]
        opacity = ${toString cfg.opacity}

        [colors]
        primary = { background = "#282828", foreground = "#ebdbb2" }
        normal = { black = "#282828", red = "#cc241d", green = "#98971a", yellow = "#d79921", blue = "#458588", purple = "#b16286", aqua = "#689d6a", gray = "#a89984" }
        bright = { black = "#928374", red = "#fb4934", green = "#b8bb26", yellow = "#fabd2f", blue = "#83a598", purple = "#d3869b", aqua = "#8ec07c", gray = "#ebdbb2" }
        cursor = { text = "#282828", cursor = "#b8bb26" }
        selection = { text = "#ebdbb2", background = "#504945" }

        [key_bindings]
        ${concatStringsSep "\n" (mapAttrsToList (key: action: "${key} = \"${action}\"") cfg.keybindings)}
      '';
    };
  };
}
