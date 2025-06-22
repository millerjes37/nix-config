{ config, lib, pkgs, ... }:

{
  # Install common development packages
  home.packages = with pkgs; [
    # Programming languages and runtimes
    nodejs_20  # LTS Node.js
    go         # Go language
    # rustup removed to avoid collision with rust-analyzer

    # Build tools
    cmake      # C/C++ build system
    gnumake    # GNU Make build system
    ninja      # Fast build system

    # Language servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    rust-analyzer
    gopls

    # Development utilities
    gh         # GitHub CLI
    direnv     # Environment management
    docker-compose # Container orchestration

    # Documentation tools
    pandoc     # Document converter

    # Formatters and linters
    nodePackages.prettier   # Code formatter
    # rustfmt removed to avoid collision with rustup
    python311Packages.black # Python formatter

    # Database tools
    dbeaver-bin    # Universal database tool

    # AI-powered code editor (Cursor) - configured per-platform in Linux/Darwin modules
  ];

  # Enable direnv for automatic environment switching
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # VSCode configuration
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # General extensions
        vscodevim.vim                 # Vim keybindings
        eamodio.gitlens               # Git integration
        yzhang.markdown-all-in-one    # Markdown support

        # Language support
        rust-lang.rust-analyzer       # Rust
        ms-python.python              # Python
        golang.go                     # Go

        # Themes & UI
        dracula-theme.theme-dracula   # Dracula theme
        pkief.material-icon-theme     # Icon theme
      ];
        userSettings = {
        "editor.fontFamily" = "'JetBrains Mono', 'FiraCode Nerd Font Mono', monospace";
        "editor.fontSize" = 14;
        "editor.lineHeight" = 1.5;
        "editor.renderWhitespace" = "boundary";
        "editor.cursorBlinking" = "smooth";
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "window.zoomLevel" = 0;
        "workbench.startupEditor" = "none";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.colorTheme" = "Dracula";
        "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
        "terminal.integrated.fontSize" = 14;
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "vim.useSystemClipboard" = true;
        "vim.leader" = " ";
        "vim.hlsearch" = true;
      };
    };
  };
}