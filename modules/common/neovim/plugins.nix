# modules/common/neovim/plugins.nix
{ lib, pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # -----------------------------------------------------------------------------
    # UI & Appearance
    # -----------------------------------------------------------------------------
    vim-airline               # Status line enhancements
    vim-airline-themes        # Themes for vim-airline
    nvim-web-devicons         # Icons for file types and UI elements
    onsails_lspkind-nvim      # Icons for LSP completion (nvim-cmp)

    # -----------------------------------------------------------------------------
    # Git Integration
    # -----------------------------------------------------------------------------
    vim-fugitive              # Comprehensive Git wrapper
    vim-gitgutter             # Shows git diff markers in the sign column

    # -----------------------------------------------------------------------------
    # Navigation & Utilities
    # -----------------------------------------------------------------------------
    telescope-nvim            # Powerful fuzzy finder
    (telescope-fzf-native-nvim.override { # FZF sorter for Telescope, faster
      buildVimPlugin = { nativeBuildInputs, ... }: {
        # telescope-fzf-native requires cmake and a C compiler
        nativeBuildInputs = [ pkgs.cmake pkgs.gcc ];
      };
    })
    nvim-tree-lua             # File explorer tree

    # -----------------------------------------------------------------------------
    # Editing Enhancements
    # -----------------------------------------------------------------------------
    numToStr_Comment-nvim     # Easy commenting
    windwp_nvim-autopairs     # Auto-close pairs

    # -----------------------------------------------------------------------------
    # Syntax, Highlighting & Language Support
    # -----------------------------------------------------------------------------
    nvim-treesitter.withAllGrammars # Advanced syntax highlighting and parsing
    nvim-lspconfig            # Configuration helpers for Neovim's LSP client
    nvim-cmp                  # Autocompletion plugin
    cmp-nvim-lsp              # LSP source for nvim-cmp
    cmp-buffer                # Buffer source for nvim-cmp
    cmp-path                  # Path source for nvim-cmp
    cmp_luasnip               # Luasnip source for nvim-cmp

    # -----------------------------------------------------------------------------
    # Snippets
    # -----------------------------------------------------------------------------
    luasnip                   # Snippet engine
    rafamadriz_friendly-snippets # Collection of snippets for various languages

    # -----------------------------------------------------------------------------
    # Colorscheme
    # -----------------------------------------------------------------------------
    gruvbox
  ];
}
