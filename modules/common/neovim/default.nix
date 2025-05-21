# modules/common/neovim/default.nix
{ config, lib, pkgs, ... }:

let
  # Define a helper for importing sub-modules for Neovim
  nvimImport = path: import path { inherit config lib pkgs; };
in
{
  # -----------------------------------------------------------------------------
  # Neovim Configuration
  # -----------------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true; # Sets nvim as default editor for git, etc.
    viAlias = true;       # Alias vi to nvim
    vimAlias = true;      # Alias vim to nvim

    extraConfig = lib.concatStringsSep "
" [
      (nvimImport ./options.nix).extraConfig
      (nvimImport ./keymaps.nix).extraConfig
      ''
        " Set theme after plugins are loaded
        colorscheme gruvbox
      ''
    ];

    extraLuaConfig = lib.concatStringsSep "
" [
      (nvimImport ./lua-config.nix).programs.neovim.extraLuaConfig
    ];

    plugins = (nvimImport ./plugins.nix).programs.neovim.plugins;
  };

  # -----------------------------------------------------------------------------
  # Supporting Packages for Neovim
  # -----------------------------------------------------------------------------
  home.packages = with pkgs; [
    # --- Language Servers ---
    pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server
    gopls
    nil_ls   # Nix
    # rust-analyzer (typically via rustup)
    # lua-language-server

    # --- Formatters ---
    nodePackages.prettier
    python3Packages.black
    stylua    # Lua
    shfmt     # Shell
    nixpkgs-fmt # Nix

    # --- Utilities for Plugins ---
    ripgrep
    fd
    git
    
    # --- For telescope-fzf-native-nvim (optional, uncomment if needed) ---
    # cmake
    # gcc 
  ];
}