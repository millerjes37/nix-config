{ config, lib, pkgs, ... }:

# Shared keybindings module
# – On Linux we reuse the detailed keybindings defined in
#   ../linux/window-management/keybindings.nix
# – On other platforms this module does nothing (but satisfies the import).

let
  isLinux = pkgs.stdenv.isLinux;
  linuxKeybindings = ../linux/window-management/keybindings.nix;
in
{
  imports = lib.optionals isLinux [ linuxKeybindings ];
} 