{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.skhd;
  defaultConfig = ''
    # On MacBook, option key is labeled as "⌥"
    :: default : echo "Mode: default"
    
    # -----------------------------------------------
    # Window Focus with just Option key
    # -----------------------------------------------
    # Window focus with option + arrow keys
    option - left  : yabai -m window --focus west || yabai -m display --focus west
    option - down  : yabai -m window --focus south || yabai -m display --focus south
    option - up    : yabai -m window --focus north || yabai -m display --focus north
    option - right : yabai -m window --focus east || yabai -m display --focus east

    # Cycle through windows in current space
    option - n : yabai -m window --focus next || yabai -m window --focus first
    option - p : yabai -m window --focus prev || yabai -m window --focus last

    # -----------------------------------------------
    # Window Movement with Option + Shift
    # -----------------------------------------------
    # Window movement with option + shift + arrow keys
    shift + option - left  : yabai -m window --warp west || yabai -m window --space prev
    shift + option - down  : yabai -m window --warp south
    shift + option - up    : yabai -m window --warp north
    shift + option - right : yabai -m window --warp east || yabai -m window --space next

    # Throw windows to adjacent displays
    shift + option - 0x21 : yabai -m window --display west; yabai -m display --focus west  # [ key
    shift + option - 0x1E : yabai -m window --display east; yabai -m display --focus east  # ] key

    # -----------------------------------------------
    # Window Resizing
    # -----------------------------------------------
    # Resize with Option + Cmd + Arrow keys
    option + cmd - left : yabai -m window --resize left:-75:0 || yabai -m window --resize right:-75:0
    option + cmd - down : yabai -m window --resize bottom:0:75 || yabai -m window --resize top:0:75
    option + cmd - up : yabai -m window --resize top:0:-75 || yabai -m window --resize bottom:0:-75
    option + cmd - right : yabai -m window --resize right:75:0 || yabai -m window --resize left:75:0

    # -----------------------------------------------
    # Window Properties (Simple toggles with just Option)
    # -----------------------------------------------
    option - f : yabai -m window --toggle zoom-fullscreen
    option - t : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
    option - s : yabai -m window --toggle split

    # -----------------------------------------------
    # Space Management (Option + Number)
    # -----------------------------------------------
    # Switch to spaces with just Option + number
    option - 1 : yabai -m space --focus 1
    option - 2 : yabai -m space --focus 2
    option - 3 : yabai -m space --focus 3
    option - 4 : yabai -m space --focus 4
    option - 5 : yabai -m space --focus 5
    option - 6 : yabai -m space --focus 6

    # Move windows to spaces with Option + Shift + number
    shift + option - 1 : yabai -m window --space 1; yabai -m space --focus 1
    shift + option - 2 : yabai -m window --space 2; yabai -m space --focus 2
    shift + option - 3 : yabai -m window --space 3; yabai -m space --focus 3
    shift + option - 4 : yabai -m window --space 4; yabai -m space --focus 4
    shift + option - 5 : yabai -m window --space 5; yabai -m space --focus 5
    shift + option - 6 : yabai -m window --space 6; yabai -m space --focus 6

    # Layout operations
    option - r : yabai -m space --rotate 90
    option - b : yabai -m space --balance

    # -----------------------------------------------
    # Application Launchers (Simple Option key)
    # -----------------------------------------------
    option - return : open -a "Alacritty"
    option - e : open -a "Finder"
    option - w : open -a "Safari"
    option - c : open -a "Visual Studio Code"

    # -----------------------------------------------
    # System Commands
    # -----------------------------------------------
    option - q : yabai -m window --close
    option - x : skhd --restart-service
    option - escape : osascript -e 'tell app "System Events" to key code 53' # Simulate Escape globally

    # -----------------------------------------------
    # Custom Layouts (Quick window arrangements)
    # -----------------------------------------------
    # Center window (mid screen)
    option - m : yabai -m window --grid 6:6:1:1:4:4
    # Side by side windows (using comma and period)
    option - 0x2F : yabai -m window --grid 1:2:0:0:1:1 # Left half (comma key)
    option - 0x2B : yabai -m window --grid 1:2:1:0:1:1 # Right half (period key)
  '';
in

{
  options.programs.skhd = {
    enable = mkEnableOption "skhd hotkey daemon";
    config = mkOption {
      type = types.lines;
      default = defaultConfig;
      description = "Contents of the skhd configuration file.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.skhd ];

    home.file.".config/skhd/skhdrc" = {
      text = cfg.config;
    };

    launchd.agents.skhd = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.skhd}/bin/skhd" ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/skhd.out.log";
        StandardErrorPath = "/tmp/skhd.err.log";
      };
    };
  };
}
