{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      i3
      i3status
      rofi
      dunst
      xss-lock
      i3lock
      dex
    ];

    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = {
          window = {
            border = 2;
            titlebar = false;
          };
          gaps = {
            inner = 10;
            outer = 0;
            smartGaps = true;
          };
          bars = [
            {
              position = "top";
              statusCommand = "i3status";
            }
          ];
          terminal = "alacritty";
          modifier = "Mod4"; # Super key
          keybindings = let
            modifier = "Mod4";
            superKey = "Mod4";
          in {
            # Focus
            "${modifier}+Left" = "focus left";
            "${modifier}+Down" = "focus down"; 
            "${modifier}+Up" = "focus up";
            "${modifier}+Right" = "focus right";
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";
            
            # Move windows
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";
            
            # Splits
            "${modifier}+s" = "split toggle";
            
            # Layouts
            "${modifier}+t" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";
            
            # Fullscreen
            "${modifier}+f" = "fullscreen toggle";
            
            # Floating
            "${modifier}+space" = "floating toggle";
            "${modifier}+Shift+space" = "focus mode_toggle";
            
            # Kill window (keep Alt+Q for compatibility)
            "${modifier}+q" = "kill";
            # Super+W to close window (your preferred binding)
            "${superKey}+w" = "kill";
            
            # Workspaces
            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            
            "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6; workspace number 6";
            
            "${modifier}+n" = "workspace next";
            "${modifier}+p" = "workspace prev";
            
            # Applications
            # Super+Enter to open Alacritty without decorations (your preferred binding)
            "${superKey}+Return" = "exec alacritty --config-file ~/.config/alacritty/floating.yml";
            "${modifier}+d" = "exec --no-startup-id rofi -show drun";
            # Super+Space to launch riced rofi (your preferred binding)
            "${superKey}+space" = "exec --no-startup-id rofi -show drun -theme gruvbox-custom";
            "${modifier}+Shift+e" = "exec --no-startup-id thunar";
            "${modifier}+Shift+w" = "exec --no-startup-id firefox";
            "${modifier}+Shift+c" = "exec --no-startup-id code";
            
            # Reload/restart
            "${modifier}+Shift+r" = "reload";
            "${modifier}+Shift+Control+r" = "restart";
            "${modifier}+Shift+q" = "exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'";
          };
          modes = {
            resize = {
              "Left" = "resize shrink width 10 px or 10 ppt";
              "Down" = "resize grow height 10 px or 10 ppt";
              "Up" = "resize shrink height 10 px or 10 ppt";
              "Right" = "resize grow width 10 px or 10 ppt";
              "h" = "resize shrink width 10 px or 10 ppt";
              "j" = "resize grow height 10 px or 10 ppt";
              "k" = "resize shrink height 10 px or 10 ppt";
              "l" = "resize grow width 10 px or 10 ppt";
              "Return" = "mode default";
              "Escape" = "mode default";
              "${config.xsession.windowManager.i3.config.modifier}+r" = "mode default";
            };
          };
          startup = [
            { command = "dex --autostart --environment i3"; notification = false; }
            { command = "xss-lock --transfer-sleep-lock -- i3lock --nofork"; notification = false; }
            { command = "nm-applet"; notification = false; }
            { command = "blueman-applet"; notification = false; }
            { command = "dunst"; notification = false; }
          ];
        };
      };
    };
  };
}