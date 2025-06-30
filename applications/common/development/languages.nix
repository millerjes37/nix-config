{ config, lib, pkgs, ... }:

{
  # Install common development packages
  home.packages = with pkgs; [
    # Programming languages and runtimes
    # Node.js provided elsewhere; avoid duplicate versions
    go         # Go language

    # Build tools
    cmake      # C/C++ build system
    gnumake    # GNU Make build system
    ninja      # Fast build system

    # Language servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    gopls

    # Development utilities
    gh         # GitHub CLI
    direnv     # Environment management
    docker-compose # Container orchestration

    # Documentation tools
    pandoc     # Document converter

    # Formatters and linters
    nodePackages.prettier   # Code formatter
    python311Packages.black # Python formatter

    # Database tools
    dbeaver-bin    # Universal database tool
  ];

  # Enable direnv for automatic environment switching
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

}