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
      ls = "${pkgs.eza}/bin/eza --color=always --icons --group-directories-first"; # Removed --color-scale as LS_COLORS will handle it
      ll = "${pkgs.eza}/bin/eza -l --icons --git --color=always --header --group-directories-first --time-style=long-iso --extended --no-filesize-metric"; # Removed --color-scale
      la = "${pkgs.eza}/bin/eza -a --icons --color=always --group-directories-first"; # Removed --color-scale
      lla = "${pkgs.eza}/bin/eza -la --icons --git --color=always --header --group-directories-first --time-style=long-iso --extended --no-filesize-metric"; # Removed --color-scale
      lt = "${pkgs.eza}/bin/eza -T --icons --color=always --level=3 --git-ignore"; # Removed --color-scale
      lta = "${pkgs.eza}/bin/eza -Ta --icons --color=always --git-ignore"; # Removed --color-scale
      ltr = "${pkgs.eza}/bin/eza -l --icons --sort=modified --reverse --color=always --header --git"; # Removed --color-scale

      # Enhanced file content viewing with syntax highlighting
      cat = "${pkgs.bat}/bin/bat --theme=Catppuccin-Mocha --style=header,grid --italic-text=always --color=always";
      less = "${pkgs.bat}/bin/bat --theme=Catppuccin-Mocha --style=header,grid,numbers --italic-text=always --color=always --paging=always";
      catp = "${pkgs.bat}/bin/bat --style=plain --color=always"; # Theme doesn't apply to plain style

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

      export PATH="$HOME/.cargo/bin:$PATH"

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

      # Environment variables with Gruvbox Dark theme
      export BAT_THEME="gruvbox-dark"
      export BAT_STYLE="header,grid"  # Show file headers and borders
      export DELTA_FEATURES="+side-by-side" # Delta theme will be set in cli.nix
      export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
      export LESS="-R" # Ensures `less` processes color codes correctly
      # Gruvbox Dark LS_COLORS (adapted from Solarized dircolors by seebi)
      export LS_COLORS="rs=0:di=01;38;5;66:ln=01;38;5;108:mh=00:pi=48;5;235;38;5;172;01:so=48;5;235;38;5;132;01:do=48;5;235;38;5;132;01:bd=48;5;235;38;5;223;01:cd=48;5;235;38;5;223;01:or=48;5;235;38;5;124;01:mi=00:su=38;5;229;48;5;124:sg=38;5;229;48;5;172:ca=00:tw=38;5;229;48;5;106:ow=38;5;66;48;5;235:st=38;5;229;48;5;72:ex=01;38;5;106:*.tar=01;38;5;124:*.tgz=01;38;5;124:*.arc=01;38;5;124:*.arj=01;38;5;124:*.taz=01;38;5;124:*.lha=01;38;5;124:*.lz4=01;38;5;124:*.lzh=01;38;5;124:*.lzma=01;38;5;124:*.tlz=01;38;5;124:*.txz=01;38;5;124:*.tzo=01;38;5;124:*.t7z=01;38;5;124:*.zip=01;38;5;124:*.z=01;38;5;124:*.dz=01;38;5;124:*.gz=01;38;5;124:*.lrz=01;38;5;124:*.lz=01;38;5;124:*.lzo=01;38;5;124:*.xz=01;38;5;124:*.zst=01;38;5;124:*.tzst=01;38;5;124:*.bz2=01;38;5;124:*.bz=01;38;5;124:*.tbz=01;38;5;124:*.tbz2=01;38;5;124:*.tz=01;38;5;124:*.deb=01;38;5;124:*.rpm=01;38;5;124:*.jar=01;38;5;124:*.war=01;38;5;124:*.ear=01;38;5;124:*.sar=01;38;5;124:*.rar=01;38;5;124:*.alz=01;38;5;124:*.ace=01;38;5;124:*.zoo=01;38;5;124:*.cpio=01;38;5;124:*.7z=01;38;5;124:*.rz=01;38;5;124:*.cab=01;38;5;124:*.jpg=01;38;5;132:*.jpeg=01;38;5;132:*.mjpg=01;38;5;132:*.mjpeg=01;38;5;132:*.gif=01;38;5;132:*.bmp=01;38;5;132:*.pbm=01;38;5;132:*.pgm=01;38;5;132:*.ppm=01;38;5;132:*.tga=01;38;5;132:*.xbm=01;38;5;132:*.xpm=01;38;5;132:*.tif=01;38;5;132:*.tiff=01;38;5;132:*.png=01;38;5;132:*.svg=01;38;5;132:*.svgz=01;38;5;132:*.mng=01;38;5;132:*.pcx=01;38;5;132:*.mov=01;38;5;132:*.mpg=01;38;5;132:*.mpeg=01;38;5;132:*.m2v=01;38;5;132:*.mkv=01;38;5;132:*.webm=01;38;5;132:*.ogm=01;38;5;132:*.mp4=01;38;5;132:*.m4v=01;38;5;132:*.mp4v=01;38;5;132:*.vob=01;38;5;132:*.qt=01;38;5;132:*.nuv=01;38;5;132:*.wmv=01;38;5;132:*.asf=01;38;5;132:*.rm=01;38;5;132:*.rmvb=01;38;5;132:*.flc=01;38;5;132:*.avi=01;38;5;132:*.fli=01;38;5;132:*.flv=01;38;5;132:*.gl=01;38;5;132:*.dl=01;38;5;132:*.xcf=01;38;5;132:*.xwd=01;38;5;132:*.yuv=01;38;5;132:*.cgm=01;38;5;132:*.emf=01;38;5;132:*.ogv=01;38;5;132:*.ogx=01;38;5;132:*.aac=00;38;5;72:*.au=00;38;5;72:*.flac=00;38;5;72:*.m4a=00;38;5;72:*.mid=00;38;5;72:*.midi=00;38;5;72:*.mka=00;38;5;72:*.mp3=00;38;5;72:*.mpc=00;38;5;72:*.ogg=00;38;5;72:*.ra=00;38;5;72:*.wav=00;38;5;72:*.oga=00;38;5;72:*.opus=00;38;5;72:*.spx=00;38;5;72:*.xspf=00;38;5;72:"

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
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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
    historySubstringSearch = {
      enable = true;
    };

    # We use zoxide directly via initExtra instead
    # of this option which doesn't exist
  };

  # Manage configuration files
  home.file.".p10k.zsh".source = ./data/p10k.zsh;
  home.file.".ripgreprc".source = ./data/ripgreprc;
  home.file.".zsh_functions".source = ./data/base.zsh;
  home.file.".zsh_aliases".source = ./data/aliases.zsh;

  # Install packages
  home.packages = with pkgs; [
    # Existing CLI tools
    eza # Modern ls replacement (fork of the now archived exa)
    bat
    fd
    ripgrep
    du-dust
    procs
    bottom
    tealdeer
    gitui
    uutils-coreutils # Modern coreutils replacement
    sd # Modern sed alternative
    choose # Modern cut alternative
    zoxide # Smarter cd command
    starship # Cross-shell prompt (though p10k is used)
    zsh-powerlevel10k # Powerlevel10k Zsh theme
    fzf # Command-line fuzzy finder
    jq # JSON processor
    yq # YAML processor
    difftastic # Diff tool that understands syntax
    delta # Git diff viewer
    hyperfine # Command-line benchmarking tool
    gawk # GNU awk
    git # Version control system
    atuin # Shell history manager
    just # Modern make alternative
    miniserve # Simple HTTP server
    ouch # Compression/decompression utility
    xh # Modern curl alternative
    qsv # CSV processing utility
    macchina # System information tool
    zellij # Terminal multiplexer

    # Common development tools
    (if pkgs.stdenv.isDarwin then clang else gcc) # C/C++ compiler
    make # Build automation tool
    python3 # Python 3 interpreter
    nodejs_20 # Node.js (LTS version 20)
    go # Go programming language
    rustc # Rust compiler
    cargo # Rust package manager
    openjdk17 # OpenJDK 17 (LTS version)
    cmake # Cross-platform build system generator
    pkg-config # Helper tool for compiling applications and libraries
    openssl # Cryptography toolkit
    curl # Command-line tool for transferring data with URLs
    wget # Command-line tool for downloading files
  ];
}