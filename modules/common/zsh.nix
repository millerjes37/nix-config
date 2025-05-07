{ config, lib, pkgs, ... }:

{
  # Enable and configure Zsh as the default shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };

    # Define shell aliases using absolute paths to ensure they work
    shellAliases = {
      # Nix aliases with platform-specific paths
      nixrebuild = if pkgs.stdenv.isDarwin 
        then "/Users/${config.home.username}/nix-config/scripts/rebuild.sh" 
        else "/home/${config.home.username}/nix-config/scripts/rebuild.sh";

      # File listing with enhanced colors (greens, teals, cyans, creams)
      ls = "${pkgs.eza}/bin/eza --color=always --icons --group-directories-first --color-scale";
      ll = "${pkgs.eza}/bin/eza -l --icons --git --color=always --header --group-directories-first --time-style=long-iso --color-scale --extended --no-filesize-metric";
      la = "${pkgs.eza}/bin/eza -a --icons --color=always --color-scale --group-directories-first";
      lla = "${pkgs.eza}/bin/eza -la --icons --git --color=always --header --group-directories-first --time-style=long-iso --color-scale --extended --no-filesize-metric";
      lt = "${pkgs.eza}/bin/eza -T --icons --color=always --color-scale --level=3 --git-ignore";
      lta = "${pkgs.eza}/bin/eza -Ta --icons --color=always --color-scale --git-ignore";
      ltr = "${pkgs.eza}/bin/eza -l --icons --sort=modified --reverse --color=always --header --color-scale --git";

      # Enhanced file content viewing with syntax highlighting
      cat = "${pkgs.bat}/bin/bat --theme=Coldark-Cold --style=header,grid --italic-text=always --color=always";
      less = "${pkgs.bat}/bin/bat --theme=Coldark-Cold --style=header,grid,numbers --italic-text=always --color=always --paging=always";
      catp = "${pkgs.bat}/bin/bat --style=plain --color=always";

      # Search tools
      find = "${pkgs.fd}/bin/fd";
      grep = "${pkgs.ripgrep}/bin/rg --smart-case";

      # Disk usage and system monitoring
      du = "${pkgs.du-dust}/bin/dust";
      ps = "${pkgs.procs}/bin/procs";
      top = "${pkgs.bottom}/bin/btm";

      # Text processing
      sd = "${pkgs.sd}/bin/sd"; # Modern sed alternative

      # Git shortcuts with enhanced colors
      g = "${pkgs.git}/bin/git";
      gs = "${pkgs.git}/bin/git status";
      gl = "${pkgs.git}/bin/git log --graph --pretty=format:'%C(cyan)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(bold cyan)<%an>%Creset'";
      gll = "${pkgs.git}/bin/git log --graph --pretty=format:'%C(cyan)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(bold cyan)<%an>%Creset' --all";

      # Editors
      v = "${pkgs.neovim}/bin/nvim";
      vim = "${pkgs.neovim}/bin/nvim";

      # Helper aliases
      help = "${pkgs.tealdeer}/bin/tldr";
      diff = "${pkgs.difftastic}/bin/difft";
    };

    # Custom initialization script for .zshrc
    initExtra = let
      homeDir = if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
    in ''
      # Load powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      
      # Ensure the rebuild script is executable
      chmod +x ${homeDir}/nix-config/scripts/rebuild.sh
      
      # Make sure we can run binaries from various locations
      path+=(
        $HOME/.nix-profile/bin
        /run/current-system/sw/bin
        /etc/profiles/per-user/$USER/bin
        /usr/local/bin
        ${if pkgs.stdenv.isDarwin then "/opt/homebrew/bin" else ""}
        ${if pkgs.stdenv.isDarwin then "/opt/local/bin" else ""}
        ${pkgs.uutils-coreutils}/bin
      )
      
      # Export the path
      export PATH

      # For absolute reliability, create function-based command aliases
      # This ensures they always work, even with complex arguments
      nixrebuild() {
        ${homeDir}/nix-config/scripts/rebuild.sh "$@"
      }
      
      # Load utility functions and aliases
      [[ -f ~/.zsh_functions ]] && source ~/.zsh_functions
      [[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
      
      # Initialize zoxide (with cd replacement)
      if command -v zoxide &>/dev/null; then
        eval "$(zoxide init zsh --cmd cd)"
      fi

      # Initialize fzf for fuzzy finding
      if [ -n "$\{commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      # Initialize atuin for enhanced shell history
      if command -v atuin >/dev/null; then
        eval "$(atuin init zsh)"
      fi

      # Environment variables with teal/cyan/green theme
      export BAT_THEME="Coldark-Cold"  # Blue/green/teal theme with excellent contrast
      export BAT_STYLE="header,grid"  # Show file headers and borders
      export DELTA_FEATURES="+side-by-side"
      export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
      export LESS="-R"
      # Custom LS_COLORS with teal/cyan/green/cream theme
      export LS_COLORS="di=01;36:ln=04;37:so=01;35:pi=01;33:ex=01;32:bd=01;36;40:cd=01;36;40:su=01;37;41:sg=01;37;42:tw=01;37;44:ow=01;37;44"

      # Zsh settings
      setopt AUTO_CD              # Change directory by typing directory name
      setopt HIST_IGNORE_DUPS     # Don't save duplicate commands
      setopt HIST_IGNORE_SPACE    # Don't save commands starting with space
      setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when HISTFILE size exceeds HISTSIZE
      setopt HIST_FIND_NO_DUPS      # Ignore duplicates when searching
      setopt SHARE_HISTORY        # Share history between sessions
      setopt EXTENDED_HISTORY     # Save timestamp and duration
      setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks
      setopt HIST_VERIFY          # Show history expansion before executing
      setopt HIST_FCNTL_LOCK      # Use system file locking for better performance
      setopt CORRECT              # Command correction
      setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells
      export HISTFILE=~/.zsh_history
      export HISTSIZE=100000
      export SAVEHIST=100000

      # Improved tab completion
      autoload -U compinit && compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' group-name ''
      zstyle ':completion:*:descriptions' format '%F{green}%B-- %d --%b%f'
      zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
      
      # Key bindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey -e  # Use emacs key bindings (more friendly for most users)
    '';

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=gray";
    };

    # Zsh plugins
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "colored-man-pages" ];
    };
    
    # Enable native syntax highlighting (don't need zplug)
    syntaxHighlighting = {
      enable = true;
      styles = {
        comment = "fg=blue,bold";
        alias = "fg=cyan";
        suffix-alias = "fg=cyan";
        global-alias = "fg=cyan";
        builtin = "fg=green";
        function = "fg=green";
        command = "fg=green";
        precommand = "fg=green";
        hashed-command = "fg=green";
        path = "fg=cyan,underline";
        path_pathseparator = "fg=cyan,bold,underline";
        globbing = "fg=cyan,bold";
        unknown-token = "fg=red,bold"; 
      };
    };
    
    # Enable history substring search
    historySubstring = {
      enable = true;
    };
    
    # Enable fast directory jumping
    zsh-z = {
      enable = true;
      options = ["enhanced"];
    };
  };

  # Manage configuration files
  home.file.".p10k.zsh".source = ./data/p10k.zsh;
  home.file.".ripgreprc".source = ./data/ripgreprc;
  home.file.".zsh_functions".source = ./data/base.zsh;
  home.file.".zsh_aliases".source = ./data/aliases.zsh;

  # Install packages
  home.packages = with pkgs; [
    eza # Modern ls replacement (fork of the now archived exa)
    bat
    fd
    ripgrep
    du-dust
    procs
    bottom
    tealdeer
    gitui
    uutils-coreutils
    sd
    choose
    zoxide
    starship
    neovim
    zsh-powerlevel10k
    fzf
    jq
    yq
    difftastic
    delta
    hyperfine
    gawk
    git
    atuin
    just
    miniserve
    ouch
    xh
    qsv
    macchina
  ];
}