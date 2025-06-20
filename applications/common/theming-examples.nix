# Example configurations for various applications using nix-colors
# This file shows how to theme different applications using the colorScheme
# You can copy these examples into your specific application configurations

{ config, lib, pkgs, ... }:

{
  # This file is for documentation/examples only
  # Copy the relevant sections to your application configs

  # Example: Kitty terminal
  programs.kitty = {
    settings = {
      foreground = "#${config.colorScheme.palette.base05}";
      background = "#${config.colorScheme.palette.base00}";
      selection_foreground = "#${config.colorScheme.palette.base00}";
      selection_background = "#${config.colorScheme.palette.base05}";
      cursor = "#${config.colorScheme.palette.base05}";
      cursor_text_color = "#${config.colorScheme.palette.base00}";
      
      # Normal colors
      color0 = "#${config.colorScheme.palette.base00}";
      color1 = "#${config.colorScheme.palette.base08}";
      color2 = "#${config.colorScheme.palette.base0B}";
      color3 = "#${config.colorScheme.palette.base0A}";
      color4 = "#${config.colorScheme.palette.base0D}";
      color5 = "#${config.colorScheme.palette.base0E}";
      color6 = "#${config.colorScheme.palette.base0C}";
      color7 = "#${config.colorScheme.palette.base05}";
      
      # Bright colors
      color8 = "#${config.colorScheme.palette.base03}";
      color9 = "#${config.colorScheme.palette.base08}";
      color10 = "#${config.colorScheme.palette.base0B}";
      color11 = "#${config.colorScheme.palette.base0A}";
      color12 = "#${config.colorScheme.palette.base0D}";
      color13 = "#${config.colorScheme.palette.base0E}";
      color14 = "#${config.colorScheme.palette.base0C}";
      color15 = "#${config.colorScheme.palette.base07}";
    };
  };

  # Example: Neovim with colorscheme
  programs.neovim = {
    extraConfig = ''
      " Set background based on colorScheme variant
      set background=${config.colorScheme.variant}
      
      " You can also set specific colors
      highlight Normal guibg=#${config.colorScheme.palette.base00} guifg=#${config.colorScheme.palette.base05}
    '';
  };

  # Example: Rofi launcher
  programs.rofi = {
    theme = {
      "*" = {
        background = "#${config.colorScheme.palette.base00}";
        foreground = "#${config.colorScheme.palette.base05}";
        selected-background = "#${config.colorScheme.palette.base02}";
        selected-foreground = "#${config.colorScheme.palette.base05}";
        border-color = "#${config.colorScheme.palette.base0D}";
      };
    };
  };

  # Example: Waybar
  programs.waybar = {
    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 13px;
      }

      window#waybar {
        background-color: #${config.colorScheme.palette.base00};
        border-bottom: 3px solid #${config.colorScheme.palette.base0D};
        color: #${config.colorScheme.palette.base05};
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #${config.colorScheme.palette.base05};
        border: none;
        border-radius: 0;
      }

      #workspaces button:hover {
        background: #${config.colorScheme.palette.base02};
      }

      #workspaces button.focused {
        background-color: #${config.colorScheme.palette.base0D};
        color: #${config.colorScheme.palette.base00};
      }

      #clock, #battery, #cpu, #memory, #network, #pulseaudio {
        padding: 0 10px;
        color: #${config.colorScheme.palette.base05};
      }

      #battery.charging, #battery.plugged {
        color: #${config.colorScheme.palette.base0B};
      }

      #battery.critical:not(.charging) {
        color: #${config.colorScheme.palette.base08};
      }
    '';
  };

  # Example: Git delta (diff viewer)
  programs.git = {
    extraConfig = {
      delta = {
        syntax-theme = "base16";
        line-numbers = true;
        decorations = true;
      };
    };
  };

  # Example: Firefox userChrome.css generation
  # This would typically be in a separate file
  home.file.".mozilla/firefox/default/chrome/userChrome.css".text = ''
    :root {
      --bg-color: #${config.colorScheme.palette.base00};
      --fg-color: #${config.colorScheme.palette.base05};
      --accent-color: #${config.colorScheme.palette.base0D};
    }

    /* Tab bar styling */
    .tab-background {
      background-color: var(--bg-color) !important;
    }

    .tab-text {
      color: var(--fg-color) !important;
    }

    .tab-background[selected="true"] {
      background-color: var(--accent-color) !important;
    }
  '';

  # Example: Dunst notification daemon
  services.dunst = {
    settings = {
      global = {
        frame_color = "#${config.colorScheme.palette.base0D}";
        separator_color = "#${config.colorScheme.palette.base02}";
      };
      urgency_low = {
        background = "#${config.colorScheme.palette.base00}";
        foreground = "#${config.colorScheme.palette.base05}";
      };
      urgency_normal = {
        background = "#${config.colorScheme.palette.base00}";
        foreground = "#${config.colorScheme.palette.base05}";
      };
      urgency_critical = {
        background = "#${config.colorScheme.palette.base08}";
        foreground = "#${config.colorScheme.palette.base00}";
      };
    };
  };

  # Example: Tmux theming
  programs.tmux = {
    extraConfig = ''
      # Status bar colors
      set -g status-bg '#${config.colorScheme.palette.base00}'
      set -g status-fg '#${config.colorScheme.palette.base05}'
      
      # Active window colors
      set -g window-status-current-bg '#${config.colorScheme.palette.base0D}'
      set -g window-status-current-fg '#${config.colorScheme.palette.base00}'
      
      # Pane border colors
      set -g pane-border-fg '#${config.colorScheme.palette.base02}'
      set -g pane-active-border-fg '#${config.colorScheme.palette.base0D}'
    '';
  };

  # Example: Zellij (terminal multiplexer)
  programs.zellij = {
    settings = {
      theme = {
        fg = "#${config.colorScheme.palette.base05}";
        bg = "#${config.colorScheme.palette.base00}";
        black = "#${config.colorScheme.palette.base00}";
        red = "#${config.colorScheme.palette.base08}";
        green = "#${config.colorScheme.palette.base0B}";
        yellow = "#${config.colorScheme.palette.base0A}";
        blue = "#${config.colorScheme.palette.base0D}";
        magenta = "#${config.colorScheme.palette.base0E}";
        cyan = "#${config.colorScheme.palette.base0C}";
        white = "#${config.colorScheme.palette.base05}";
        orange = "#${config.colorScheme.palette.base09}";
      };
    };
  };
} 