{ config, lib, pkgs, ... }:

{
  # Enable and configure Zsh as the default shell
  programs.zsh = {
    enable = true;

    # Custom initialization script for `.zshrc`
    initExtra = ''
      # Enable powerlevel10k instant prompt
      if [[ -r "$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$\{(%):-%n}.zsh" ]]; then
        source "$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$\{(%):-%n}.zsh"
      fi

      # Custom PATH additions for macOS compatibility
      path+=(/usr/local/bin)         # Common macOS binary path
      path+=(/opt/homebrew/bin)      # Homebrew binary path (Apple Silicon)
      path+=(/opt/local/bin)         # MacPorts binary path

      # Aliases for modern Rust-based tools
      alias ls='eza'                # Modern ls replacement
      alias ll='eza -l'             # Long listing
      alias la='eza -a'             # Show hidden files
      alias lla='eza -la'           # Long listing with hidden files
      alias cat='bat'               # Syntax-highlighted cat
      alias find='fd'               # Faster find alternative
      alias grep='rg'               # Faster, user-friendly grep
      
      # Custom aliases for Nix configuration
      alias nixrebuild="$HOME/nix-config/scripts/rebuild.sh"
      alias v="nvim"
      alias vim="nvim"

      # Additional Zsh settings
      setopt AUTO_CD                # Automatically change directories without `cd`
      setopt HIST_IGNORE_DUPS       # Don't save duplicate commands in history
      setopt SHARE_HISTORY          # Share history across sessions
      export HISTFILE=~/.zsh_history # History file location
      export HISTSIZE=10000         # Number of commands to keep in memory
      export SAVEHIST=10000         # Number of commands to save to file
      
      # Source powerlevel10k config
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
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
      theme = "robbyrussell"; # Base theme - will be overridden by powerlevel10k
      plugins = [
        "git"
        "sudo" 
        "colored-man-pages"
      ];
    };
  };

  # Create p10k.zsh file with teal-focused configuration
  home.file.".p10k.zsh".text = ''
    # Generated p10k configuration
    # Customized for teal/cyan colorway with bullet-train style
    
    # Temporarily change options
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'
    
    function p10k-on-pre-prompt() {
      # Show ruler only when at least 2 lines get displayed
      local RULER_LEN=''${#RULER}
      if (( LINES < RULER_LEN + 3 )); then
        typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
      else
        typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─'
      fi
    }
    
    function p10k-on-post-prompt() {
      # Show ruler only when at least 2 lines get displayed
      if [[ -n "$P9K_COMMAND" ]]; then
        RULER=
      fi
    }
    
    typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      dir                     # current directory
      vcs                     # git status
      newline                 # \n
      prompt_char             # prompt symbol
    )
    
    typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      status                  # exit code of the last command
      command_execution_time  # duration of the last command
      background_jobs         # presence of background jobs
      time                    # current time
    )
    
    # Customize connection
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=
    
    # Prompt styles
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=076
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
    
    # Directory
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=074
    typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=072
    typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=080
    typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
    
    # Git colors
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=076
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=172
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=208
    
    # Status/Command time
    typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=076
    typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=244
    
    # Settings
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
    typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
    typeset -g POWERLEVEL9K_BACKGROUND=

    # Configure newline
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
    typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─'
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%F{008}╰─'
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{008}╰─'
  '';
  
  # Install required packages  
  home.packages = with pkgs; [
    eza                  # Modern ls replacement (exa fork)
    bat                  # Syntax-highlighted cat
    fd                   # Faster find alternative
    ripgrep              # Faster grep replacement
    neovim               # Modern Vim fork
    zsh-powerlevel10k    # Powerlevel10k theme
  ];
}