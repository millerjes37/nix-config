{ config, lib, pkgs, stdenv, extraImports ? [], ... }:

{
  # Import all the modules we've created
  imports = [
    ./modules/zsh.nix
    ./modules/alacritty.nix
    ./modules/emacs.nix
    # ./modules/quick_terminal.nix  # Temporarily disabled
    # ./modules/neovim.nix  # Temporarily disabled
  ] ++ extraImports;

  # Enable and configure each module
  programs.zsh.enable = true;
  programs.alacritty.enable = true;  # Settings are in the alacritty module
  programs.emacs.enable = true;
  programs.yabai.enable = lib.mkIf stdenv.isDarwin false; # Managed externally for better stability
  programs.skhd.enable = lib.mkIf stdenv.isDarwin false;  # Managed externally for better stability

  # Home-manager settings
  home.stateVersion = "25.05";  # Adjust to your home-manager version
  home.username = "jacksonmiller";  # Replace with your username
  home.homeDirectory = if stdenv.isDarwin then "/Users/jacksonmiller" else "/home/jacksonmiller";

  # Required packages for window management, terminal, and Civitas development
  home.packages = with pkgs; [
    # Window manager tools (macOS only)
  ] ++ lib.optionals stdenv.isDarwin [
    yabai      # Tiling window manager
    skhd       # Hotkey daemon
  ] ++ [
    # Terminal and tools (cross-platform)
    alacritty  # Terminal emulator
    ripgrep    # Fast grep
    jq         # JSON processor
    # Civitas development tools
    rustup     # Rust toolchain
    python3    # Python 3
    dioxus-cli # Dioxus CLI for web development
  ];
}