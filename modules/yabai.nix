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
    
    # Configure terminal window positioning (temporarily commented out)
    # yabai -m rule --add title="quick_terminal" manage=off sticky=on layer=above
    # yabai -m rule --add title="quick_terminal" grid=6:6:1:4:4:2
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

  config = mkIf cfg.enable {
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
