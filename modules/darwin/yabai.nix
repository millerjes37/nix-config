{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.yabai;
  defaultConfig = ''
    #!/usr/bin/env sh
    yabai -m config layout bsp
    yabai -m config window_placement second_child
    yabai -m config top_padding 10
    yabai -m config bottom_padding 10
    yabai -m config left_padding 10
    yabai -m config right_padding 10
    yabai -m config window_gap 10
    
    # Window opacity (requires SIP to be disabled)
    yabai -m config window_opacity on
    yabai -m config active_window_opacity 1.0
    yabai -m config normal_window_opacity 0.9
    
    # Mouse settings
    yabai -m config mouse_follows_focus on
    yabai -m config focus_follows_mouse autoraise
    yabai -m config mouse_modifier alt
    yabai -m config mouse_action1 move
    yabai -m config mouse_action2 resize
    yabai -m config mouse_drop_action swap
    
    # Rules for specific applications
    yabai -m rule --add app="^System Settings$" manage=off
    yabai -m rule --add app="^Calculator$" manage=off
    yabai -m rule --add app="^Karabiner-Elements$" manage=off
    yabai -m rule --add app="^QuickTime Player$" manage=off
  '';
in

{
  options.programs.yabai = {
    enable = mkEnableOption "yabai tiling window manager";
    config = mkOption {
      type = types.lines;
      default = defaultConfig;
      description = "Contents of the yabairc configuration file.";
    };
  };

  config = mkIf pkgs.stdenv.isDarwin {
    home.packages = [ pkgs.yabai ];

    home.file.".yabairc" = {
      text = cfg.config;
      executable = true;
    };

    launchd.agents.yabai = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.yabai}/bin/yabai" ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/yabai.out.log";
        StandardErrorPath = "/tmp/yabai.err.log";
      };
    };
  };
}