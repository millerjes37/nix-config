{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    home.packages = with pkgs; [
      i3
      i3status
      i3blocks      # Status bar
      rofi          # Application launcher
      dunst         # Notification daemon
      xss-lock      # Screen lock
      i3lock        # Lock screen
      dex           # Autostart applications
      picom         # Compositor for transparency
      feh           # Wallpaper setting
      arandr        # Display management
      wmctrl        # Window control
      xdotool       # X automation
      
      # Window grid snapping utility (replacement for omakub)
      wmutils-core    # Window manipulation utilities
      wmutils-opt     # Optional utilities for window management
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
              colors = {
                background = "#282828";
                statusline = "#ebdbb2";
                separator = "#666666";
                focusedWorkspace = {
                  border = "#4c7899";
                  background = "#285577";
                  text = "#ffffff";
                };
                activeWorkspace = {
                  border = "#333333";
                  background = "#5f676a";
                  text = "#ffffff";
                };
                inactiveWorkspace = {
                  border = "#333333";
                  background = "#222222";
                  text = "#888888";
                };
                urgentWorkspace = {
                  border = "#2f343a";
                  background = "#900000";
                  text = "#ffffff";
                };
              };
              fonts = {
                names = [ "FiraMono Nerd Font Mono" ];
                size = 10.0;
              };
            }
          ];
          terminal = "alacritty";
          modifier = "Mod1"; # Alt key
          keybindings = let
            modifier = "Mod1";
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
            "${modifier}+t" = "exec --no-startup-id \"${pkgs.writeScript "i3-grid-snap" ''
              #!/usr/bin/env bash
              
              # Get active window id
              WINDOW=$(xdotool getactivewindow)
              
              # Get screen dimensions
              SCREEN_WIDTH=$(xdotool getdisplaygeometry | awk '{print $1}')
              SCREEN_HEIGHT=$(xdotool getdisplaygeometry | awk '{print $2}')
              
              # Create a dmenu with grid options
              GRID=$(echo -e "1x1\n1x2\n2x1\n2x2\n3x2\n3x3" | rofi -dmenu -p "Select grid position")
              
              if [[ -z "$GRID" ]]; then
                exit 0
              fi
              
              # Parse grid dimensions
              COLS=$(echo $GRID | cut -d'x' -f1)
              ROWS=$(echo $GRID | cut -d'x' -f2)
              
              # Get position from user
              POS_OPTIONS=""
              for ((row=1; row<=ROWS; row++)); do
                for ((col=1; col<=COLS; col++)); do
                  POS_OPTIONS="$POS_OPTIONS$col,$row\n"
                done
              done
              
              POS=$(echo -e $POS_OPTIONS | rofi -dmenu -p "Select position (column,row)")
              
              if [[ -z "$POS" ]]; then
                exit 0
              fi
              
              # Parse position
              COL=$(echo $POS | cut -d',' -f1)
              ROW=$(echo $POS | cut -d',' -f2)
              
              # Calculate window dimensions and position
              WIDTH=$((SCREEN_WIDTH / COLS))
              HEIGHT=$((SCREEN_HEIGHT / ROWS))
              X=$(( (COL-1) * WIDTH ))
              Y=$(( (ROW-1) * HEIGHT ))
              
              # Apply to window
              xdotool windowmove $WINDOW $X $Y
              xdotool windowsize $WINDOW $WIDTH $HEIGHT
            ''}\""; # Grid snap action
            
            "${modifier}+e" = "layout toggle split";
            
            # Fullscreen
            "${modifier}+f" = "fullscreen toggle";
            
            # Floating
            "${modifier}+space" = "floating toggle";
            "${modifier}+Shift+space" = "focus mode_toggle";
            
            # Kill window
            "${modifier}+q" = "kill";
            
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
            "${modifier}+Return" = "exec alacritty";
            "${modifier}+d" = "exec --no-startup-id rofi -show drun";
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
            { command = "feh --bg-fill ~/.config/wall.jpg"; notification = false; } # Set wallpaper
            { command = "picom -b"; notification = false; } # Start compositor
          ];
        };
      };
    };
    
    # i3status configuration
    home.file.".config/i3status/config".text = ''
      general {
        colors = true
        interval = 5
        color_good = "#8ec07c"
        color_degraded = "#fabd2f"
        color_bad = "#fb4934"
      }
      
      order += "cpu_usage"
      order += "memory"
      order += "disk /"
      order += "wireless _first_"
      order += "ethernet _first_"
      order += "battery all"
      order += "volume master"
      order += "tztime local"
      
      cpu_usage {
        format = " CPU: %usage "
      }
      
      memory {
        format = " RAM: %used / %total "
        threshold_degraded = "1G"
        format_degraded = " MEMORY < %available "
      }
      
      disk "/" {
        format = " Disk: %avail "
      }
      
      wireless _first_ {
        format_up = " W: %essid %quality "
        format_down = " W: down "
      }
      
      ethernet _first_ {
        format_up = " E: %ip "
        format_down = " E: down "
      }
      
      battery all {
        format = " %status %percentage "
        format_down = "No battery"
        last_full_capacity = true
        integer_battery_capacity = true
        status_chr = "⚡"
        status_bat = "🔋"
        status_unk = "?"
        status_full = "☻"
        low_threshold = 15
        threshold_type = time
      }
      
      volume master {
        format = " ♪: %volume "
        format_muted = " ♪: muted "
        device = "default"
        mixer = "Master"
        mixer_idx = 0
      }
      
      tztime local {
        format = " %Y-%m-%d %H:%M "
      }
    '';
    
    # Picom (compositor) configuration
    home.file.".config/picom.conf".text = ''
      # Shadows
      shadow = true;
      shadow-radius = 15;
      shadow-offset-x = -15;
      shadow-offset-y = -15;
      shadow-opacity = 0.5;
      
      # Fading
      fading = true;
      fade-delta = 5;
      fade-in-step = 0.03;
      fade-out-step = 0.03;
      
      # Transparency / Opacity
      inactive-opacity = 0.95;
      frame-opacity = 1.0;
      inactive-opacity-override = false;
      
      # Background blurring
      blur-background = true;
      blur-method = "dual_kawase";
      blur-strength = 5;
      
      # General settings
      backend = "glx";
      vsync = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
    '';
    
    # Create a sample wallpaper
    home.file.".config/wall.jpg".source = pkgs.fetchurl {
      url = "https://images.unsplash.com/photo-1419242902214-272b3f66ee7a";
      sha256 = "sha256-rnLlUF3eRpKxFz38dLHEQO+/drx2QzXM6XpBR9jtDYQ=";
    };
  };
}