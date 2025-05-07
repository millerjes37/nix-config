{ config, lib, pkgs, extraImports ? [], ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Common modules for all platforms
  commonModules = [
    ./modules/zsh.nix
    ./modules/alacritty.nix
    ./modules/emacs.nix
    # ./modules/quick_terminal.nix  # Temporarily disabled
    # ./modules/neovim.nix  # Temporarily disabled
  ];
  
  # Platform-specific modules come from extraImports
in
{
  # Import all modules with proper platform detection
  imports = commonModules ++ extraImports;

  # Enable and configure each module
  programs.zsh.enable = true;
  programs.alacritty.enable = true;  # Settings are in the alacritty module
  programs.emacs.enable = true;
  
  # Enable window managers based on platform
  programs.yabai.enable = lib.mkIf isDarwin true;
  programs.skhd.enable = lib.mkIf isDarwin true;
  programs.i3.enable = lib.mkIf isLinux true;

  # Home-manager settings
  home.stateVersion = "25.05";  # Adjust to your home-manager version
  
  # These are now set in flake.nix via the homeManagerConfiguration function
  # home.username = "jacksonmiller";
  # home.homeDirectory = if isDarwin then "/Users/jacksonmiller" else "/home/jacksonmiller";

  # Required packages for development
  home.packages = with pkgs; [
    # Common tools for all platforms
    alacritty  # Terminal emulator
    ripgrep    # Fast grep
    jq         # JSON processor
    rustup     # Rust toolchain
    python3    # Python 3
    dioxus-cli # Dioxus CLI for web development
    
    # Platform-specific packages
  ] 
  # Darwin (macOS) specific packages
  ++ lib.optionals isDarwin [
    yabai      # Tiling window manager
    skhd       # Hotkey daemon
  ] 
  # Linux specific packages
  ++ lib.optionals isLinux [
    i3         # Linux window manager alternative
    rofi       # Application launcher for Linux
    dunst      # Notification daemon
  ];
}