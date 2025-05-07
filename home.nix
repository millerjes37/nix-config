{ config, lib, pkgs, extraImports ? [], ... }:

# Allow unfree packages like VSCode
pkgs = import <nixpkgs> { 
  config = { 
    allowUnfree = true;
  }; 
};

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Common modules for all platforms
  commonModules = [
    ./modules/common/zsh.nix
    ./modules/common/alacritty.nix
    ./modules/common/emacs.nix
    ./modules/common/development.nix # Development tools
    ./modules/common/cli.nix         # CLI utilities
  ];
  
  # Platform-specific modules are included via extraImports
in
{
  # Import all modules with proper platform detection
  imports = commonModules ++ extraImports;

  # Home-manager settings
  home.stateVersion = "25.05";  # Adjust to your home-manager version
  
  # Install common packages
  home.packages = with pkgs; [
    # Common CLI tools
    ripgrep
    jq
    fd
    bat
    atuin        # Shell history
    bottom       # System monitor
    
    # Development tools
    git
    gh           # GitHub CLI
    rustup
    python3
  ];
}