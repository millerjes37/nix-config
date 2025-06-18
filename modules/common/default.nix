{ config, lib, pkgs, ... }:

{
  # Import modules more directly to avoid recursion
  imports = [
    ./zsh.nix
    ./alacritty.nix
    ./emacs.nix
    # ./nixvim.nix # Added new nixvim config
    ./fonts.nix
    ./development.nix
    ./helix.nix
    ./keepassxc.nix
  ];

  home.packages = with pkgs; [
  # Development tools
  git
  gh                  # GitHub CLI
  gitui               # TUI Git client
  lazygit             # TUI Git client (Go)
  just                # Command runner
  python3             # Python
  starship            # Shell prompt (Rust)
  cargo               # Rust package manager
  dprint              # Code formatter (Rust)

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
  broot               # File navigator (Rust)
  tokei               # Code stats (Rust)
  zellij              # Terminal multiplexer (Rust)
  gum                 # CLI scripting prompts (Go)
  onefetch            # Git repo summary (Rust)

  # Text processing
  sd                  # Better sed
  delta               # Better diff
  difftastic          # Syntax-aware diff
  miller              # CSV/JSON processor (Rust)

  # System monitoring
  btop                # Resource monitor
  glances             # System monitor (Python)
  bandwhich           # Network bandwidth monitor (Rust)

  # Network tools
  curl
  wget
  dog                 # DNS lookup (Rust)
  mtr                 # Better traceroute
  nmap                # Network discovery
  trippy              # Ping/traceroute TUI (Rust)
  gping               # Graphical ping (Rust)
  feroxbuster         # Web directory brute-forcer (Rust)

  # File compression
  ouch                # Compression tool
  p7zip               # 7zip
  unzip
  zstd                # High-performance compression

  # File transfer
  rsync
  miniserve           # Simple HTTP server

  # Security tools
  age                 # File encryption (Go)
  fx                  # JSON viewer (JS)
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
    userEmail = "jackson@civitas.ltd";  # Replace with your email

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