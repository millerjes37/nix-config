{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.skhd;
  defaultConfig = ''
    # Define hyper key as option(⌥) + command(⌘)
    # On MacBook, option key is labeled as "⌥"
    :: default : echo "Mode: default"
    
    # -----------------------------------------------
    # Window Focus (Navigate with Precision)
    # -----------------------------------------------
    alt + cmd - h : yabai -m window --focus west || yabai -m display --focus west
    alt + cmd - j : yabai -m window --focus south || yabai -m display --focus south
    alt + cmd - k : yabai -m window --focus north || yabai -m display --focus north
    alt + cmd - l : yabai -m window --focus east || yabai -m display --focus east

    # Cycle through windows in current space
    alt + cmd - n : yabai -m window --focus next || yabai -m window --focus first
    alt + cmd - p : yabai -m window --focus prev || yabai -m window --focus last

    # -----------------------------------------------
    # Window Movement (Warp Speed Relocation)
    # -----------------------------------------------
    shift + alt + cmd - h : yabai -m window --warp west || yabai -m window --space prev
    shift + alt + cmd - j : yabai -m window --warp south
    shift + alt + cmd - k : yabai -m window --warp north
    shift + alt + cmd - l : yabai -m window --warp east || yabai -m window --space next

    # Throw windows to adjacent displays (using [ and ] for display movement)
    shift + alt + cmd - 0x21 : yabai -m window --display west; yabai -m display --focus west  # [ key
    shift + alt + cmd - 0x1E : yabai -m window --display east; yabai -m display --focus east  # ] key

    # -----------------------------------------------
    # Window Resizing (Pixel-Perfect Control)
    # -----------------------------------------------
    # Using arrow keys for resizing (easier to remember on laptop)
    alt + cmd - left : yabai -m window --resize left:-75:0 || yabai -m window --resize right:-75:0
    alt + cmd - down : yabai -m window --resize bottom:0:75 || yabai -m window --resize top:0:75
    alt + cmd - up : yabai -m window --resize top:0:-75 || yabai -m window --resize bottom:0:-75
    alt + cmd - right : yabai -m window --resize right:75:0 || yabai -m window --resize left:75:0

    # Fine-tune resizing (25px increments)
    # Simplified to use shift for fine control (easier on laptop)
    shift + alt + cmd - left : yabai -m window --resize left:-25:0
    shift + alt + cmd - down : yabai -m window --resize bottom:0:25
    shift + alt + cmd - up : yabai -m window --resize top:0:-25
    shift + alt + cmd - right : yabai -m window --resize right:25:0

    # -----------------------------------------------
    # Window Properties (Toggle Like a Pro)
    # -----------------------------------------------
    alt + cmd - f : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
    alt + cmd - z : yabai -m window --toggle zoom-fullscreen
    alt + cmd - s : yabai -m window --toggle split
    alt + cmd - m : yabai -m window --toggle native-fullscreen
    alt + cmd - t : yabai -m window --toggle sticky; yabai -m window --toggle topmost

    # -----------------------------------------------
    # Space Management (Mission Control Mastery)
    # -----------------------------------------------
    alt + cmd - 1 : yabai -m space --focus 1
    alt + cmd - 2 : yabai -m space --focus 2
    alt + cmd - 3 : yabai -m space --focus 3
    alt + cmd - 4 : yabai -m space --focus 4
    alt + cmd - 5 : yabai -m space --focus 5
    alt + cmd - 6 : yabai -m space --focus 6

    # Move windows to spaces
    shift + alt + cmd - 1 : yabai -m window --space 1; yabai -m space --focus 1
    shift + alt + cmd - 2 : yabai -m window --space 2; yabai -m space --focus 2
    shift + alt + cmd - 3 : yabai -m window --space 3; yabai -m space --focus 3
    shift + alt + cmd - 4 : yabai -m window --space 4; yabai -m space --focus 4
    shift + alt + cmd - 5 : yabai -m window --space 5; yabai -m space --focus 5
    shift + alt + cmd - 6 : yabai -m window --space 6; yabai -m space --focus 6

    # Rotate and balance spaces
    alt + cmd - r : yabai -m space --rotate 90
    alt + cmd - b : yabai -m space --balance

    # -----------------------------------------------
    # Application Launchers (Instant Access)
    # -----------------------------------------------
    alt + cmd - return : open -a "Alacritty"
    alt + cmd - e : open -a "Finder"
    alt + cmd - w : open -a "Safari"
    alt + cmd - v : open -a "Visual Studio Code"  # 'v' for VSCode

    # -----------------------------------------------
    # System Commands (Power User Shortcuts)
    # -----------------------------------------------
    alt + cmd - q : yabai -m window --close
    alt + cmd - x : skhd -r # Restart skhd
    alt + cmd - lcmd : osascript -e 'tell app "System Events" to sleep' # Lock screen
    alt + cmd - escape : osascript -e 'tell app "System Events" to key code 53' # Simulate Escape globally

    # -----------------------------------------------
    # Custom Layouts (Snap to Perfection)
    # -----------------------------------------------
    # Center window (mid screen) - easily remembered as "middle"
    alt + cmd - m : yabai -m window --grid 6:6:1:1:4:4
    # Center window (smaller) - easily remembered as "center"
    alt + cmd - c : yabai -m window --grid 4:4:1:1:2:2
    # Side by side windows (using slash and period)
    alt + cmd - 0x2F : yabai -m window --grid 1:2:0:0:1:1 # Left half (comma key)
    alt + cmd - 0x2B : yabai -m window --grid 1:2:1:0:1:1 # Right half (period key)
    
    # Quick terminal (Option+Command+T for Terminal)
    alt + cmd - t : open -na "Alacritty"
    # Quick terminal full command when implemented (Option+Command+Return)
    cmd + alt - 0x24 : open -na "Alacritty"
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
