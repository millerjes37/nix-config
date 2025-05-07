{ config, lib, pkgs, ... }:

{
  # Import modules more directly to avoid recursion
  imports = [
    ../zsh.nix
    ../alacritty.nix
    ../emacs.nix
  ];
  
  # Common packages for both platforms
  home.packages = with pkgs; [
    # Development tools
    git
    gh                  # GitHub CLI
    gitui               # TUI Git client
    just                # Command runner
    rustup              # Rust toolchain
    python3             # Python
    
    # CLI utilities
    ripgrep             # Fast search
    fd                  # Alternative to find
    jq                  # JSON processor
    yq                  # YAML processor
    fzf                 # Fuzzy finder
    bat                 # Better cat
    eza                 # Better ls
    du-dust             # Better du
    bottom              # Better top
    procs               # Better ps
    tealdeer            # TL;DR pages
    xh                  # HTTP client
    hyperfine           # Benchmarking
    atuin               # Shell history
    zoxide              # Smart cd command
    
    # Text processing
    sd                  # Better sed
    delta               # Better diff
    difftastic          # Syntax-aware diff
    
    # Network tools
    curl
    wget
    bind                # For dig command
    mtr                 # Better traceroute
    nmap                # Network discovery
    
    # File compression
    ouch                # Compression tool
    p7zip               # 7zip
    unzip
    
    # File transfer
    rsync
    miniserve           # Simple HTTP server
  ];
  
  # Common home-manager settings for both platforms
  programs = {
    home-manager.enable = true;
  };
  
  # Create directory for common shell scripts
  home.file.".local/bin" = lib.mkIf (builtins.pathExists ../scripts/common) {
    source = ../scripts/common;
  };
  
  # Common git configuration
  programs.git = {
    enable = true;
    userName = "Jackson Miller";
    userEmail = "jackson@example.com";  # Replace with your email
    
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
    
  # Configure commonly used editors
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  
  # Configure common shell tools
  programs.fzf.enable = true;
  programs.starship.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;
}