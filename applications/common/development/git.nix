{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    gh                  # GitHub CLI
    gitui               # TUI Git client
    lazygit             # TUI Git client (Go)
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Jackson Miller";
    userEmail = "jackson@civitas.ltd";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
      core.autocrlf = "input";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "gruvbox-dark";
      };
    };
  };
} 