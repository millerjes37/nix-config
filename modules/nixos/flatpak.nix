{ config, pkgs, lib, ... }:

{
  # Enable flatpak support
  services.flatpak.enable = true;
  
  # Install flatpak packages system-wide
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}