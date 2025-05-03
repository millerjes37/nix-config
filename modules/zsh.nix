{ config, lib, pkgs, ... }:

{
  # Enable and configure Zsh as the default shell
  programs.zsh = {
    enable = true;

    # Custom initialization script for `.zshrc`
    initExtra = ''
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

      # Use standard prompt (powerlevel10k removed to simplify)
      PS1='%B%F{green}%n@%m%f:%F{blue}%~%f%#%b '

      # Additional Zsh settings
      setopt AUTO_CD                # Automatically change directories without `cd`
      setopt HIST_IGNORE_DUPS       # Don’t save duplicate commands in history
      setopt SHARE_HISTORY          # Share history across sessions
      export HISTFILE=~/.zsh_history # History file location
      export HISTSIZE=10000         # Number of commands to keep in memory
      export SAVEHIST=10000         # Number of commands to save to file
    '';

    # Set environment variables
    sessionVariables = {
      EDITOR = "nvim";             # Set Neovim as the default editor
      VISUAL = "nvim";             # Set Neovim as the default visual editor
      PAGER = "less";              # Default pager for man pages, etc.
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=gray"; # Style for autosuggestions
    };

    # Add Zsh plugins for enhanced functionality
    plugins = [];
  };

  # Explicitly define `.zshrc` to ensure it’s created
  home.file.".zshrc" = {
    text = ''
      # Managed by Home Manager - do not edit directly
      # Custom PATH adjustments (also in initExtra for consistency)
      path+=(/usr/local/bin)
      path+=(/opt/homebrew/bin)
      path+=(/opt/local/bin)

      # Aliases for Rust-based tools
      alias ls='eza'
      alias ll='eza -l'
      alias la='eza -a'
      alias lla='eza -la'
      alias cat='bat'
      alias find='fd'
      alias grep='rg'

      # Use standard prompt (powerlevel10k removed to simplify)
      PS1='%B%F{green}%n@%m%f:%F{blue}%~%f%#%b '

      # Additional Zsh options
      setopt AUTO_CD
      setopt HIST_IGNORE_DUPS
      setopt SHARE_HISTORY
      export HISTFILE=~/.zsh_history
      export HISTSIZE=10000
      export SAVEHIST=10000
      export EDITOR=nvim
      export VISUAL=nvim
    '';
  };

  # Install required packages  
  home.packages = with pkgs; [
    eza                  # Modern ls replacement (exa fork)
    bat                  # Syntax-highlighted cat
    fd                   # Faster find alternative
    ripgrep              # Faster grep replacement
    neovim               # Modern Vim fork
  ];
}