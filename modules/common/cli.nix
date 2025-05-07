{ config, lib, pkgs, ... }:

{
  # Configure common CLI tools
  
  # Atuin - Better shell history
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fulltext";
      filter_mode = "global";
      style = "full";
    };
  };
  
  # Starship - Cross-shell prompt
  programs.starship = {
    enable = false; # Disabled in favor of p10k
  };
  
  # Bat - Better cat
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
      style = "numbers,changes,header";
    };
  };
  
  # Ripgrep
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git/"
    ];
  };
  
  # Git
  programs.git = {
    enable = true;
    userName = "Jackson Miller";
    userEmail = "jackson@civitas.ltd";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        side-by-side = true;
        line-numbers = true;
      };
    };
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      editor = "nvim";
    };
  };
  
  # Neovim basic configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix        # Nix syntax highlighting
      gruvbox        # Color scheme
      vim-surround   # Surrounding text objects
      vim-commentary # Comment handling
    ];
    extraConfig = ''
      " Basic settings
      set number relativenumber
      set tabstop=2 shiftwidth=2 expandtab
      set autoindent smartindent
      set cursorline
      set ignorecase smartcase
      set termguicolors
      set mouse=a
      
      " Set color scheme
      colorscheme gruvbox
      set background=dark
      
      " Keymaps
      let mapleader = " "
      nnoremap <leader>ff :find<space>
      nnoremap <leader>w :write<cr>
      nnoremap <leader>q :quit<cr>
    '';
  };
}