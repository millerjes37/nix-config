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

      # Environment variables with Catppuccin Mocha theme
      export BAT_THEME="Catppuccin-Mocha"
      export BAT_STYLE="header,grid"  # Show file headers and borders
      export DELTA_FEATURES="+side-by-side" # Delta theme will be set in cli.nix
      export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
      export LESS="-R" # Ensures `less` processes color codes correctly
      # Catppuccin Mocha LS_COLORS from https://github.com/catppuccin/dircolors
      export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;40:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

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
    zellij
  ];
}