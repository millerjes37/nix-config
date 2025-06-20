{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Search and navigation
    ripgrep             # Fast search
    fd                  # Alternative to find
    fzf                 # Fuzzy finder
    bat                 # Better cat
    eza                 # Better ls
    broot               # File navigator (Rust)
    zoxide              # Smart cd command
    
    # Text processing
    jq                  # JSON processor
    yq                  # YAML processor
    sd                  # Better sed
    delta               # Better diff
    difftastic          # Syntax-aware diff
    miller              # CSV/JSON processor (Rust)
    
    # System utilities
    du-dust             # Better du
    bottom              # Better top
    procs               # Better ps
    tealdeer            # TL;DR pages
    hyperfine           # Benchmarking
    tokei               # Code stats (Rust)
    onefetch            # Git repo summary (Rust)
    
    # Shell enhancement
    atuin               # Shell history
    gum                 # CLI scripting prompts (Go)
  ];

  # Configure related programs
  programs = {
    fzf.enable = true;
    bat.enable = true;
    zoxide.enable = true;
  };
} 