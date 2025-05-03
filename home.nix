{ config, lib, pkgs, ... }:

{
  # Import all the modules we've created
  imports = [
    ./modules/zsh.nix
    ./modules/yabai.nix
    ./modules/skhd.nix
    ./modules/alacritty.nix
    ./modules/emacs.nix
  ];

  # Enable and configure each module
  programs.zsh.enable = true;
  programs.yabai.enable = true;
  programs.skhd.enable = true;
  programs.alacritty.enable = true;  # Settings are in the alacritty module
  programs.emacs.enable = true;

  # Home-manager settings
  home.stateVersion = "25.05";  # Adjust to your home-manager version
  home.username = "jacksonmiller";  # Replace with your username
  home.homeDirectory = "/Users/jacksonmiller";  # Replace with your home directory

  # Optional: Add additional packages
  home.packages = with pkgs; [
    neovim  # Example package
    ripgrep  # Example package
  ];
}
