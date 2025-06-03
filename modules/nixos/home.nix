{ config, pkgs, inputs, lib, ... }:

{
  home.username = "jules";
  home.homeDirectory = "/home/jules";

  # Home Manager configuration options go here
  home.stateVersion = "23.11"; # Or your desired version

  # Example of enabling a basic package:
  home.packages = [
    pkgs.hello # A simple package to test
    pkgs.waybar # Install Waybar
    pkgs.alacritty # Install Alacritty
    pkgs.zsh      # Install Zsh
    pkgs.zellij   # Install Zellij
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "alacritty"; # We will install Alacritty later
      "$mainMod" = "SUPER"; # Using SUPER as mainMod for now, can be changed

      # Example binds
      "bind" = [
        # Open terminal (Alacritty)
        "CONTROL, RETURN, exec, $terminal"

        # Workspace navigation (Ctrl + Number)
        "CONTROL, 1, workspace, 1"
        "CONTROL, 2, workspace, 2"
        "CONTROL, 3, workspace, 3"
        "CONTROL, 4, workspace, 4"
        "CONTROL, 5, workspace, 5"
        "CONTROL, 6, workspace, 6"

        # Move active window to workspace (Ctrl + Shift + Number)
        "CONTROL SHIFT, 1, movetoworkspace, 1"
        "CONTROL SHIFT, 2, movetoworkspace, 2"
        "CONTROL SHIFT, 3, movetoworkspace, 3"
        "CONTROL SHIFT, 4, movetoworkspace, 4"
        "CONTROL SHIFT, 5, movetoworkspace, 5"
        "CONTROL SHIFT, 6, movetoworkspace, 6"
      ];

      # Basic window rules (examples)
      "windowrulev2" = [
        "opacity 0.9 0.8,class:^(alacritty)$"
        "float,class:^(pavucontrol)$"
      ];

      # Autostart some programs (example, will be refined)
      "exec-once" = [
        "waybar" # We will install and configure Waybar next
        # "hyprpaper" # If we add hyprpaper
      ];
    };
    # Systemd integration can be enabled if desired
    # systemd.enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "cpu" "memory" ];

        "hyprland/workspaces" = {
          format = "{name}: {icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };
        "hyprland/window" = {
          format = "{}"; # Shows current app title
        };
        "clock" = {
          format = " {:%H:%M  %Y-%m-%d}"; # Clock and date
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "tray" = {
          icon-size = 21;
          spacing = 10;
        };
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
        "network" = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-disconnected = "Disconnected ⚠";
          tooltip-format = "{ifname} via {gwaddr} ";
          on-click = "nm-connection-editor"; # NetworkManager connection editor
        };
        "cpu" = {
          format = "CPU: {usage}% ";
          tooltip = true;
        };
        "memory" = {
          format = "MEM: {}% ";
        };
      };
    };
  };

  # Placeholder for programs configuration
  programs = {
    # Configurations for programs like zsh, git, etc. will go here
  };
}
