{ config, lib, pkgs, inputs, ... }:

{
  # NixOS-specific home-manager configuration
  # This should be minimal as system packages are handled by the NixOS system configuration
  
  # Home Manager settings for NixOS
  home = {
    username = "jackson";
    homeDirectory = lib.mkForce "/home/jackson";
    stateVersion = "25.05";
  };

  # Minimal packages for home-manager user session
  home.packages = with pkgs; [
    # Only user-specific tools that need home-manager configuration
    git       # User git config
    neovim    # Text editor
  ];

  # Basic programs configuration
  programs = {
    home-manager.enable = true;
    
    # Basic git configuration
    git = {
      enable = true;
      userName = "Jackson Miller";
      userEmail = "jackson@civitas.ltd";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };
    
    # Basic shell
    zsh.enable = true;
  };

  # Wayland-specific configurations for Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # Basic configuration - detailed config is in the system module
    systemd.enable = true;
  };

  # XDG configuration
  xdg.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
} 