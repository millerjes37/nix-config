{ config, lib, pkgs, ... }:

{
  # Linux-specific services and systemd user services
  
  # Example systemd user services
  systemd.user.services = {
    # Example service
    # my-service = {
    #   Unit = {
    #     Description = "My custom service";
    #     After = [ "graphical-session-pre.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };
    #   Install = { WantedBy = [ "graphical-session.target" ]; };
    #   Service = {
    #     ExecStart = "${pkgs.hello}/bin/hello";
    #     Restart = "on-failure";
    #   };
    # };
  };
} 