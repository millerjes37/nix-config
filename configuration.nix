{ config, pkgs, ... }:

{
  # Enable yabai for tiling window management
  services.yabai.enable = true;

  # Enable skhd for key bindings
  services.skhd.enable = true;
  services.skhd.skhdConfig = ''
    # Switch to Spaces 1-6 with Option + 1-6
    option + 1 : yabai -m space --focus 1
    option + 2 : yabai -m space --focus 2
    option + 3 : yabai -m space --focus 3
    option + 4 : yabai -m space --focus 4
    option + 5 : yabai -m space --focus 5
    option + 6 : yabai -m space --focus 6
    # Launch transparent terminal with Cmd + /
    cmd + / : /Users/jacksonmiller/.local/bin/launch_transparent_terminal.sh
  '';

  # Install system-wide packages
  environment.systemPackages = with pkgs; [
    alacritty  # Terminal emulator
    jq         # Used in the terminal launch script
    yabai      # Tiling Window Manager
];

  # Enable Homebrew integration
  nix-homebrew.enable = true;
}
