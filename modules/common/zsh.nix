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
      
      # Initialize zoxide for better directory navigation
      if command -v zoxide >/dev/null; then
        eval "$(zoxide init zsh)"
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
      setopt AUTO_CD
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY
      setopt HIST_REDUCE_BLANKS
      export HISTFILE=~/.zsh_history
      export HISTSIZE=50000
      export SAVEHIST=50000

      # Completion
      autoload -U compinit && compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Functions
      mkcd() { mkdir -p "$1" && cd "$1"; }
      ftext() { ${pkgs.fd}/bin/fd . -tf -x ${pkgs.ripgrep}/bin/rg --files-with-matches "$1"; }
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
  };

  # Manage configuration files
  home.file.".p10k.zsh".text = builtins.readFile ../p10k.zsh;
  home.file.".ripgreprc".text = builtins.readFile ../ripgreprc;

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