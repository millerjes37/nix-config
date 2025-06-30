{ config, lib, pkgs, ... }:

{
  # Comprehensive collection of oxidized (Rust-based) CLI tools and performance utilities
  # Prioritizing speed, reliability, and modern UX over traditional Unix tools
  
  home.packages = with pkgs; [
    # Search and navigation (Rust-powered)
    ripgrep             # rg - blazingly fast text search (Rust)
    fd                  # find alternative with intuitive syntax (Rust)
    fzf                 # fuzzy finder for everything (Go)
    bat                 # cat clone with syntax highlighting (Rust)
    eza                 # ls alternative with git integration (Rust)
    broot               # tree view and file navigator (Rust)
    zoxide              # z/autojump alternative with frecency (Rust)
    tree-sitter         # incremental parsing system (Rust)
    
    # Text processing and manipulation (Rust-powered)
    jq                  # JSON processor and query language
    yq-go               # YAML/XML/TOML processor (Go)
    sd                  # sed alternative with simpler syntax (Rust)
    delta               # enhanced git diff viewer (Rust)
    difftastic          # structural diff tool that understands syntax (Rust)
    miller              # CSV/JSON/YAML data processor (C but fast)
    htmlq               # HTML processor like jq (Rust)
    dasel               # query and modify data structures (Go)
    choose              # cut alternative with simpler syntax (Rust)
    parallel            # GNU parallel for command execution
    
    # System monitoring and performance (Rust-powered)
    du-dust             # du alternative with tree view (Rust)
    bottom              # top/htop alternative with graphs (Rust)
    procs               # ps alternative with colored output (Rust)
    bandwhich           # network bandwidth monitor by process (Rust)
    zenith              # system monitor with zoom and search (Rust)
    macchina            # neofetch alternative (Rust)
    
    # File and directory utilities (Rust-powered)
    lsd                 # ls alternative with icons and colors (Rust)
    tre-command         # tree alternative with regex filtering (Rust)
    ouch                # compression/decompression utility (Rust)
    zip                 # compression utilities
    unzip               # decompression utilities
    zstd                # fast compression algorithm
    
    # Network utilities (Rust-powered)
    dog                 # dig alternative with JSON output (Rust)
    gping               # ping with graph output (Rust)
    curlie              # curl alternative with easier syntax (Go)
    xh                  # HTTPie clone with JSON support (Rust)
    websocat            # WebSocket client (Rust)
    miniserve           # simple HTTP file server (Rust)
    
    # Development utilities (Rust-powered)
    tokei               # code statistics and line counting (Rust)
    onefetch            # git repository summary (Rust)
    gitui               # terminal git UI (Rust)
    lazygit             # simple terminal UI for git (Go)
    gitmux              # git status in tmux (Go)
    gh                  # GitHub CLI
    
    # Text editing and manipulation
    helix               # modal text editor (Rust)
    micro               # simple terminal text editor (Go)
    
    # Performance benchmarking and testing
    hyperfine           # command-line benchmarking tool (Rust)
    criterion           # statistical benchmarking (Rust)
    # dhatViewer          # heap profiler viewer (Rust) – temporarily disabled due to missing darwin package
    
    # Shell and terminal enhancement
    # atuin               # shell history with sync and search (Rust) - temporarily disabled
    starship            # cross-shell prompt (Rust)
    gum                 # shell scripting with style (Go)
    charm               # CLI framework components
    vivid               # LS_COLORS generator (Rust)
    
    # File format conversion and processing
    pandoc              # universal document converter
    # rpmfile             # extract data from RPM files (Rust) – unavailable on Darwin
    qsv                 # CSV data processing toolkit (Rust)
    frawk               # AWK alternative (Rust)
    # polars-cli          # fast DataFrame operations (Rust) – unavailable on Darwin
    
    # Security and encryption utilities
    age                 # simple file encryption (Go)
    rage                # Rust implementation of age (Rust)
    
    # Archive and backup utilities  
    rustic              # restic-compatible backup (Rust)
    
    # Terminal multiplexing and session management
    zellij              # terminal multiplexer (Rust)
    tmux                # traditional terminal multiplexer
    
    # Process management
    pueue               # command queue manager (Rust)
    
    # Media utilities
    ffmpeg              # multimedia processing
    imagemagick         # image manipulation
    
    # Modern Unix replacements collection
    uutils-coreutils    # Rust implementation of GNU coreutils
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific oxidized tools
    xcp                 # cp alternative with progress bars (Rust)
    btop                # resource monitor (C++)
    iotop               # I/O monitor
    nethogs             # network bandwidth per process
    psensor             # hardware temperature monitor
    
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific tools
    swift-format        # Swift code formatter
    asitop              # Apple Silicon system monitor (macOS)
  ];

  # Configure related programs with enhanced settings
  programs = {
    # Fuzzy finder with enhanced configuration
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type file --follow --hidden --exclude .git";
      defaultOptions = [ 
        "--height 50%" 
        "--border" 
        "--layout=reverse"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
      fileWidgetCommand = "fd --type file --follow --hidden --exclude .git";
      fileWidgetOptions = [ "--preview 'bat --color=always --style=numbers --line-range=:500 {}'" ];
      historyWidgetOptions = [ "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'" ];
    };
    
    # Bat (better cat) with configuration
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
        map-syntax = [
          "*.jenkinsfile:Groovy"
          "*.props:Java Properties"
        ];
      };
    };
    
    # Zoxide (smart cd) with configuration
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];  # Replace cd command
    };
    
    # Atuin (shell history)
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
        show_preview = true;
        max_preview_height = 4;
        word_jump_mode = "emacs";
        scroll_exit = false;
      };
    };
    
    # Starship prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        directory = {
          style = "blue bold";
          truncation_length = 4;
          truncation_symbol = "…/";
        };

        character = {
          vicmd_symbol = "[❮](green)";
        };

        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        git_state = {
          format = "([$state( $progress_current/$progress_total)]($style)) ";
          style = "bright-black";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
          min_time = 2000;
        };
      };
    };
  };

  # Shell aliases for oxidized tools
  programs.zsh.shellAliases = {
    # Enhanced ls alternatives
    "l" = "eza -la --icons --git --group-directories-first";
    "lsd-tree" = "lsd --tree";
    
    # Search and find
    "search" = "rg --smart-case --follow --hidden";
    
    # System monitoring
    "htop" = "bottom";
    "net" = "bandwhich";
    "sys" = "macchina";
    
    # Text processing
    "delta-diff" = "delta";
    
    # Network utilities
    "ping" = "gping";
    "dig" = "dog";
    "curl" = "xh";
    "wget" = "xh --download";
    "http" = "xh";
    "serve" = "miniserve";
    
    # File operations
    "cp" = "xcp";
    "compress" = "ouch compress";
    "decompress" = "ouch decompress";
    
    # Git enhancements
    "git-ui" = "gitui";
    "lazygit" = "lazygit";
    "onefetch" = "onefetch";
    
    # Development utilities
    "lines" = "tokei";
    "cloc" = "tokei";
    "bench" = "hyperfine";
    "benchmark" = "hyperfine";
    
    # Terminal and session management
    "tmux" = "zellij";
    "zj" = "zellij";
    
    # Process management
    "queue" = "pueue";
    "pueue-add" = "pueue add";
    "pueue-status" = "pueue status";
    
    # Data processing
    "csv" = "qsv";
    "awk" = "frawk";
    
    # Quick utilities
    "weather" = "curl wttr.in";
    "cheat" = "tldr";
    "tldr" = "tealdeer";
  };

  # Environment variables for oxidized tools
  home.sessionVariables = {
    # Ripgrep configuration
    RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.ripgreprc";
    
    # FZF configuration
    FZF_DEFAULT_COMMAND = "fd --type file --follow --hidden --exclude .git";
    FZF_ALT_C_COMMAND = "fd --type directory --follow --hidden --exclude .git";
    
    # Bat theme
    BAT_THEME = "TwoDark";
    
    # Less configuration
    LESS = "-R";
    
    # Zoxide configuration
    _ZO_ECHO = "1";
    _ZO_RESOLVE_SYMLINKS = "1";
  };

  # Force our preferred FZF CTRL-T command to avoid conflicts with the default
  home.sessionVariables.FZF_CTRL_T_COMMAND = lib.mkForce "$FZF_DEFAULT_COMMAND";

  # Configuration files for tools
  home.file = {
    # Ripgrep configuration
    ".ripgreprc".text = ''
      --max-columns=150
      --max-columns-preview
      --smart-case
      --follow
      --hidden
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!target/*
      --glob=!.cargo/*
      --glob=!*.lock
      --colors=line:none
      --colors=line:style:bold
      --colors=path:fg:green
      --colors=path:style:bold
      --colors=match:fg:yellow
      --colors=match:style:bold
    '';
    
    # Bottom (btm) configuration
    ".config/bottom/bottom.toml".text = ''
      [flags]
      dot_marker = false
      temperature_type = "celsius"
      rate = 1000
      left_legend = true
      current_usage = true
      group_processes = true
      case_sensitive = false
      whole_word = false
      regex = false
      show_table_scroll_position = true
      disable_click = false
      no_write = false
      
      [colors]
      table_header_color = "LightBlue"
      all_cpu_color = "Red"
      avg_cpu_color = "Green"
      cpu_core_colors = ["LightMagenta", "LightYellow", "LightCyan", "LightGreen", "LightBlue", "LightRed", "Cyan", "Green", "Blue", "Red"]
      ram_color = "LightMagenta"
      swap_color = "LightYellow"
      rx_color = "LightCyan"
      tx_color = "LightGreen"
      widget_title_color = "Gray"
      border_color = "Gray"
      highlighted_border_color = "LightBlue"
      text_color = "Gray"
      selected_text_color = "Black"
      selected_bg_color = "LightBlue"
      graph_color = "Gray"
      high_battery_color = "green"
      medium_battery_color = "yellow"
      low_battery_color = "red"
    '';
  };
} 