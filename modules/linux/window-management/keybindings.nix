{ config, lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  # Use Super key (Mod4) for window manager bindings
  superKey = "Mod4";
  
  # Alacritty command without decorations
  alacrittyCmd = "alacritty --class=floating-terminal";
  
  # Rofi command with custom theme
  rofiCmd = "rofi -show drun -theme gruvbox-custom";
in
{
  config = lib.mkIf isLinux {
    # Install required packages for keybindings
    home.packages = with pkgs; [
      xdotool        # For window manipulation
      wmctrl         # Alternative window control tool
    ];

    # Custom Alacritty wrapper for floating terminal without decorations
    home.file.".local/bin/floating-alacritty" = {
      text = ''
        #!/usr/bin/env bash
        alacritty --class=floating-terminal --config-file=${config.home.homeDirectory}/.config/alacritty/floating.yml
      '';
      executable = true;
    };

    # Floating Alacritty configuration without decorations
    home.file.".config/alacritty/floating.yml".text = ''
      window:
        decorations: "None"
        startup_mode: "Windowed"
        dynamic_title: true
        opacity: 0.95
        padding:
          x: 8
          y: 8
        dimensions:
          columns: 100
          lines: 30
        position:
          x: 200
          y: 100
        
      # Use the same settings as main alacritty config but without decorations
      import:
        - ~/.config/alacritty/alacritty.yml
    '';

    # Super key bindings for common window manager operations
    # These will be used by the window manager configuration
    programs.bash.sessionVariables = {
      SUPER_KEY = superKey;
      ALACRITTY_CMD = alacrittyCmd;
      ROFI_CMD = rofiCmd;
    };

    programs.zsh.sessionVariables = {
      SUPER_KEY = superKey;
      ALACRITTY_CMD = alacrittyCmd;
      ROFI_CMD = rofiCmd;
    };

    # Create a script for closing windows with Super+W
    home.file.".local/bin/close-window" = {
      text = ''
        #!/usr/bin/env bash
        # Close the currently focused window
        window_id=$(xdotool getwindowfocus)
        if [ "$window_id" != "0" ]; then
          xdotool windowclose "$window_id"
        fi
      '';
      executable = true;
    };

    # Add local bin to PATH
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
  };
} 