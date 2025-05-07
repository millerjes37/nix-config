{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.i3;
  defaultConfig = ''
    # i3 config file (v4)

    # Set mod key (Mod1=Alt, Mod4=Super/Windows key)
    set $mod Mod1

    # Font for window titles
    font pango:monospace 10

    # -----------------------------------------------
    # Window Focus - similar to yabai/skhd
    # -----------------------------------------------
    # Focus windows with $mod+arrow keys
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Alternative focus keys
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    # -----------------------------------------------
    # Window Movement
    # -----------------------------------------------
    # Move windows with $mod+Shift+arrow keys
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # Alternative movement keys
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    # -----------------------------------------------
    # Window Resizing
    # -----------------------------------------------
    # Resize mode
    mode "resize" {
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
    }
    bindsym $mod+r mode "resize"

    # -----------------------------------------------
    # Window Properties
    # -----------------------------------------------
    # Toggle fullscreen
    bindsym $mod+f fullscreen toggle

    # Toggle floating
    bindsym $mod+space floating toggle

    # Change focus between tiling / floating windows
    bindsym $mod+Shift+space focus mode_toggle

    # Split orientation
    bindsym $mod+s split toggle
    
    # Container layout
    bindsym $mod+t layout tabbed
    bindsym $mod+e layout toggle split

    # Kill focused window
    bindsym $mod+q kill

    # -----------------------------------------------
    # Workspace Management
    # -----------------------------------------------
    # Define workspace names
    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"

    # Switch to workspace
    bindsym $mod+1 workspace number $ws1
    bindsym $mod+2 workspace number $ws2
    bindsym $mod+3 workspace number $ws3
    bindsym $mod+4 workspace number $ws4
    bindsym $mod+5 workspace number $ws5
    bindsym $mod+6 workspace number $ws6

    # Move focused container to workspace and follow
    bindsym $mod+Shift+1 move container to workspace number $ws1; workspace number $ws1
    bindsym $mod+Shift+2 move container to workspace number $ws2; workspace number $ws2
    bindsym $mod+Shift+3 move container to workspace number $ws3; workspace number $ws3
    bindsym $mod+Shift+4 move container to workspace number $ws4; workspace number $ws4
    bindsym $mod+Shift+5 move container to workspace number $ws5; workspace number $ws5
    bindsym $mod+Shift+6 move container to workspace number $ws6; workspace number $ws6

    # Next/prev workspace
    bindsym $mod+n workspace next
    bindsym $mod+p workspace prev

    # -----------------------------------------------
    # Application Launchers
    # -----------------------------------------------
    # Terminal
    bindsym $mod+Return exec alacritty

    # Rofi (application launcher)
    bindsym $mod+d exec --no-startup-id rofi -show drun
    
    # Common applications
    bindsym $mod+Shift+e exec --no-startup-id thunar
    bindsym $mod+Shift+w exec --no-startup-id firefox
    bindsym $mod+Shift+c exec --no-startup-id code

    # -----------------------------------------------
    # System Commands
    # -----------------------------------------------
    # Reload the configuration file
    bindsym $mod+Shift+r reload

    # Restart i3 inplace
    bindsym $mod+Shift+Control+r restart

    # Exit i3
    bindsym $mod+Shift+q exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

    # -----------------------------------------------
    # Appearance
    # -----------------------------------------------
    # Window borders
    default_border pixel 2
    default_floating_border pixel 2
    hide_edge_borders smart

    # Gaps
    gaps inner 10
    gaps outer 0
    smart_gaps on

    # Colors
    # class                 border  backgr. text    indicator child_border
    client.focused          #4c7899 #285577 #ffffff #2e9ef4   #285577
    client.focused_inactive #333333 #5f676a #ffffff #484e50   #5f676a
    client.unfocused        #333333 #222222 #888888 #292d2e   #222222
    client.urgent           #2f343a #900000 #ffffff #900000   #900000
    client.placeholder      #000000 #0c0c0c #ffffff #000000   #0c0c0c
    client.background       #ffffff

    # -----------------------------------------------
    # i3bar
    # -----------------------------------------------
    bar {
        status_command i3status
        position top
        tray_output primary
        
        colors {
            background #222222
            statusline #ffffff
            separator  #666666

            focused_workspace  #4c7899 #285577 #ffffff
            active_workspace   #333333 #5f676a #ffffff
            inactive_workspace #333333 #222222 #888888
            urgent_workspace   #2f343a #900000 #ffffff
            binding_mode       #2f343a #900000 #ffffff
        }
    }

    # -----------------------------------------------
    # Autostart applications
    # -----------------------------------------------
    exec --no-startup-id dex --autostart --environment i3
    exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
    exec --no-startup-id nm-applet
    exec --no-startup-id blueman-applet
    exec --no-startup-id dunst
  '';
in

{
  options.programs.i3 = {
    enable = mkEnableOption "i3 window manager";
    config = mkOption {
      type = types.lines;
      default = defaultConfig;
      description = "Contents of the i3 configuration file.";
    };
  };

  # We'll handle the platform check in home.nix

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      i3
      i3status
      rofi
      dunst
      xss-lock
      i3lock
      dex
    ];

    home.file.".config/i3/config" = {
      text = cfg.config;
    };

    # Add xsession configuration for i3
    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = null; # We're using our own config, not the home-manager one
        extraConfig = cfg.config;
      };
    };
  };
}