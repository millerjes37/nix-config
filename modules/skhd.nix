{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.skhd;
  defaultConfig = ''
    # -----------------------------------------------
    # Window Focus (Navigate with Precision)
    # -----------------------------------------------
    hyper - h : yabai -m window --focus west || yabai -m display --focus west
    hyper - j : yabai -m window --focus south || yabai -m display --focus south
    hyper - k : yabai -m window --focus north || yabai -m display --focus north
    hyper - l : yabai -m window --focus east || yabai -m display --focus east

    # Cycle through windows in current space
    hyper - n : yabai -m window --focus next || yabai -m window --focus first
    hyper - p : yabai -m window --focus prev || yabai -m window --focus last

    # -----------------------------------------------
    # Window Movement (Warp Speed Relocation)
    # -----------------------------------------------
    shift + hyper - h : yabai -m window --warp west || yabai -m window --space prev
    shift + hyper - j : yabai -m window --warp south
    shift + hyper - k : yabai -m window --warp north
    shift + hyper - l : yabai -m window --warp east || yabai -m window --space next

    # Throw windows to adjacent displays
    shift + hyper - left : yabai -m window --display west; yabai -m display --focus west
    shift + hyper - right : yabai -m window --display east; yabai -m display --focus east

    # -----------------------------------------------
    # Window Resizing (Pixel-Perfect Control)
    # -----------------------------------------------
    ctrl + hyper - h : yabai -m window --resize left:-75:0 || yabai -m window --resize right:-75:0
    ctrl + hyper - j : yabai -m window --resize bottom:0:75 || yabai -m window --resize top:0:75
    ctrl + hyper - k : yabai -m window --resize top:0:-75 || yabai -m window --resize bottom:0:-75
    ctrl + hyper - l : yabai -m window --resize right:75:0 || yabai -m window --resize left:75:0

    # Fine-tune resizing (25px increments)
    ctrl + shift + hyper - h : yabai -m window --resize left:-25:0
    ctrl + shift + hyper - j : yabai -m window --resize bottom:0:25
    ctrl + shift + hyper - k : yabai -m window --resize top:0:-25
    ctrl + shift + hyper - l : yabai -m window --resize right:25:0

    # -----------------------------------------------
    # Window Properties (Toggle Like a Pro)
    # -----------------------------------------------
    hyper - f : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
    hyper - z : yabai -m window --toggle zoom-fullscreen
    hyper - s : yabai -m window --toggle split
    hyper - m : yabai -m window --toggle native-fullscreen
    hyper - t : yabai -m window --toggle sticky; yabai -m window --toggle topmost

    # -----------------------------------------------
    # Space Management (Mission Control Mastery)
    # -----------------------------------------------
    hyper - 1 : yabai -m space --focus 1
    hyper - 2 : yabai -m space --focus 2
    hyper - 3 : yabai -m space --focus 3
    hyper - 4 : yabai -m space --focus 4
    hyper - 5 : yabai -m space --focus 5
    hyper - 6 : yabai -m space --focus 6
    hyper - 7 : yabai -m space --focus 7
    hyper - 8 : yabai -m space --focus 8
    hyper - 9 : yabai -m space --focus 9

    # Move windows to spaces
    shift + hyper - 1 : yabai -m window --space 1; yabai -m space --focus 1
    shift + hyper - 2 : yabai -m window --space 2; yabai -m space --focus 2
    shift + hyper - 3 : yabai -m window --space 3; yabai -m space --focus 3
    shift + hyper - 4 : yabai -m window --space 4; yabai -m space --focus 4
    shift + hyper - 5 : yabai -m window --space 5; yabai -m space --focus 5
    shift + hyper - 6 : yabai -m window --space 6; yabai -m space --focus 6
    shift + hyper - 7 : yabai -m window --space 7; yabai -m space --focus 7
    shift + hyper - 8 : yabai -m window --space 8; yabai -m space --focus 8
    shift + hyper - 9 : yabai -m window --space 9; yabai -m space --focus 9

    # Rotate and balance spaces
    hyper - r : yabai -m space --rotate 90
    hyper - b : yabai -m space --balance

    # -----------------------------------------------
    # Application Launchers (Instant Access)
    # -----------------------------------------------
    hyper - return : open -a "Terminal"
    hyper - e : open -a "Finder"
    hyper - w : open -a "Safari"
    hyper - c : open -a "Visual Studio Code"

    # -----------------------------------------------
    # System Commands (Power User Shortcuts)
    # -----------------------------------------------
    hyper - q : yabai -m window --close
    hyper - x : skhd -r # Restart skhd
    hyper - lcmd : osascript -e 'tell app "System Events" to sleep' # Lock screen
    hyper - escape : osascript -e 'tell app "System Events" to key code 53' # Simulate Escape globally

    # -----------------------------------------------
    # Custom Layouts (Snap to Perfection)
    # -----------------------------------------------
    hyper - g : yabai -m window --grid 6:6:1:1:4:4 # Center window (large)
    hyper - v : yabai -m window --grid 1:2:0:0:1:1 # Left half
    hyper - n : yabai -m window --grid 1:2:1:0:1:1 # Right half
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
