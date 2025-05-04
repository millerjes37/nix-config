{ config, lib, pkgs, ... }:

{
  # Import all the modules we've created
  imports = [
    ./modules/zsh.nix
    ./modules/yabai.nix
    ./modules/skhd.nix
    ./modules/alacritty.nix
    # ./modules/quick_terminal.nix  # Temporarily disabled 
    ./modules/emacs.nix
    # ./modules/neovim.nix  # Temporarily disabled
  ];

  # Enable and configure each module
  programs.zsh.enable = true;
  programs.yabai.enable = false; # Managed externally for better stability
  programs.skhd.enable = false;  # Managed externally for better stability
  programs.alacritty.enable = true;  # Settings are in the alacritty module
  programs.emacs.enable = true;

  # Home-manager settings
  home.stateVersion = "25.05";  # Adjust to your home-manager version
  home.username = "jacksonmiller";  # Replace with your username
  home.homeDirectory = "/Users/jacksonmiller";  # Replace with your home directory

  # Required packages for window management and terminal
  home.packages = with pkgs; [
    # Window manager tools
    yabai      # Tiling window manager
    skhd       # Hotkey daemon
    
    # Terminal and tools
    alacritty  # Terminal emulator
    ripgrep    # Fast grep
    jq         # JSON processor
  ];
}
