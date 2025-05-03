{ config, lib, pkgs, ... }:

{
  # Enable and configure Zsh as the default shell
  programs.zsh = {
    enable = true;
    
    # Define shell aliases - these are more reliably loaded than aliases in initExtra
    shellAliases = {
      # Nix aliases
      nixrebuild = "$HOME/nix-config/scripts/rebuild.sh";
      
      # File listing (eza)
      ls = "eza --color=auto";
      ll = "eza -l --icons --git --color=always";
      la = "eza -a --icons --color=always";
      lla = "eza -la --icons --git --color=always";
      lt = "eza -T --icons --color=always"; # Tree view
      lta = "eza -Ta --icons --color=always"; # Tree view with hidden files
      
      # File content viewing
      cat = "bat --style=plain";
      less = "bat --style=plain --paging=always";
      
      # Search tools
      find = "fd";
      grep = "rg --smart-case";
      
      # File navigation
      cd = "z"; # Use zoxide for smart directory jumping
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      
      # Rust coreutils
      du = "dust";
      ps = "procs";
      top = "btm";
      
      # Editors
      v = "nvim";
      vim = "nvim";
      
      # Helper aliases
      help = "tldr"; # tealdeer command
      diff = "difft"; # difftastic
    };

    # Custom initialization script for `.zshrc`
    initExtra = ''
      # Load powerlevel10k if it exists
      if [[ -f ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      fi
      
      # Load p10k configuration if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # Custom PATH additions for macOS compatibility
      path+=(/usr/local/bin)         # Common macOS binary path
      path+=(/opt/homebrew/bin)      # Homebrew binary path (Apple Silicon)
      path+=(/opt/local/bin)         # MacPorts binary path

      # Aliases are defined in shellAliases

      # Initialize zoxide (better cd)
      if command -v zoxide > /dev/null; then
        eval "$(zoxide init zsh)"
      fi
      
      # Initialize fzf for better history search
      if [ -n "$\{commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
      
      # Configure bat (syntax highlighting for cat)
      export BAT_THEME="Dracula"
      export BAT_STYLE="plain"
      
      # Configure delta (better git diff)
      export DELTA_FEATURES="+side-by-side"
      
      # Configure ripgrep
      export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
      
      # Additional Zsh settings
      setopt AUTO_CD                # Automatically change directories without `cd`
      setopt HIST_IGNORE_DUPS       # Don't save duplicate commands in history
      setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
      setopt SHARE_HISTORY          # Share history across sessions
      setopt EXTENDED_HISTORY       # Record timestamp in history
      setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history
      export HISTFILE=~/.zsh_history # History file location
      export HISTSIZE=50000         # Number of commands to keep in memory
      export SAVEHIST=50000         # Number of commands to save to file
      
      # Improved tab completion
      autoload -U compinit
      compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion
    '';

    # Set environment variables
    sessionVariables = {
      EDITOR = "nvim";             # Set Neovim as the default editor
      VISUAL = "nvim";             # Set Neovim as the default visual editor
      PAGER = "less";              # Default pager for man pages, etc.
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=gray"; # Style for autosuggestions
    };

    # Add Zsh plugins for enhanced functionality
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    
    # Enable oh-my-zsh for compatibility with some plugins
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo" 
        "colored-man-pages"
      ];
    };
  };
  
  # Create p10k.zsh in the user's home directory
  # We'll use text directly since relative paths are tricky
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;
  
  # Add config for ripgrep
  home.file.".ripgreprc".text = builtins.readFile ./ripgreprc;

  # Install required packages  
  home.packages = with pkgs; [
    # Modern CLI tools (Rust-based)
    eza                  # Modern ls replacement (exa fork)
    bat                  # Syntax-highlighted cat
    fd                   # Faster find alternative
    ripgrep              # Faster grep replacement
    du-dust              # Better du (disk usage)
    procs                # Modern ps replacement 
    bottom               # Modern top replacement
    tealdeer             # Simplified man pages (tldr)
    gitui                # Terminal UI for git
    uutils-coreutils     # Rust implementation of GNU coreutils
    sd                   # Intuitive find & replace (sed alternative)
    choose               # Cut alternative with field selection
    zoxide               # Smarter cd command
    starship             # Alternative prompt (backup for powerlevel10k)
    
    # Development tools
    neovim               # Modern Vim fork
    zsh-powerlevel10k    # Powerlevel10k theme
    fzf                  # Fuzzy finder
    jq                   # JSON processor
    yq                   # YAML processor (like jq)
    difftastic           # Modern diff tool
    delta                # Better git diffs
    hyperfine            # Command-line benchmarking tool
  ];
}