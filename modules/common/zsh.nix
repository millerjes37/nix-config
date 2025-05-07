{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    
    # Install plugins
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
    ];

    # Common shell aliases
    shellAliases = {
      # General aliases
      ls = "ls --color=auto";
      ll = "ls -la";
      grep = "grep --color=auto";
      ".." = "cd ..";
      
      # Git aliases
      gst = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gl = "git log";
      gp = "git push";
      
      # Nix aliases
      nrs = "cd ~/nix-config && bash scripts/rebuild.sh";
      
      # Platform-specific
    } // lib.optionalAttrs isDarwin {
      # macOS specific aliases
      brewup = "brew update && brew upgrade";
    } // lib.optionalAttrs isLinux {
      # Linux specific aliases
      update = "sudo apt update && sudo apt upgrade -y";
    };

    # Shell initialization
    initExtra = ''
      # Load powerlevel10k config
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      
      # Enable Atuin shell history
      eval "$(atuin init zsh)"
      
      # Add ~/.local/bin to PATH (common location for user scripts)
      export PATH=$HOME/.local/bin:$PATH
      
      # Set default editor
      export EDITOR="nvim"
      export VISUAL="nvim"
      
      # Platform-specific configuration
      ${if isDarwin then ''
        # macOS specific settings
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '' else ''
        # Linux specific settings
      ''}
    '';
  };
  
  # Configure p10k theme
  home.file.".p10k.zsh".source = ../p10k.zsh;
}