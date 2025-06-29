{ config, lib, pkgs, ... }:

{
  # AI-powered development tools configuration
  # This module sets up various AI tools for enhanced developer experience

  # Core AI development packages
  home.packages = with pkgs; [
    # AI-powered editors
    code-cursor                     # Cursor - AI-first code editor
    
    # Python AI/ML tools (for AI development and tooling)
    python311Full                   # Full Python with all modules
    python311Packages.pip           # Python package installer
    python311Packages.virtualenv    # Virtual environment management
    python311Packages.poetry        # Python dependency management
    
    # Node.js for AI tool installations
    nodejs_20                       # Node.js LTS for npm-based AI tools
    nodePackages.npm                # Node package manager
    nodePackages.yarn               # Alternative package manager
    
    # Git and collaboration tools enhanced for AI workflows
    git-lfs                         # Git Large File Storage (for AI models)
    
    # Terminal AI helpers
    gh                              # GitHub CLI with Copilot integration
  ];

  # Install Claude Code CLI via npm
  home.activation.install-claude-code = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v npm >/dev/null 2>&1; then
      echo "Installing Claude Code CLI via npm..."
      $DRY_RUN_CMD npm install -g @anthropic-ai/claude-code-cli 2>/dev/null || echo "Claude Code CLI installation skipped (may not be available)"
    fi
  '';

  # Enhanced Cursor configuration
  home.file.".cursor/settings.json" = {
    text = builtins.toJSON {
      # AI and Copilot settings
      "github.copilot.enable" = true;
      "cursor.enableCopilot" = true;
      "cursor.aiEnabled" = true;
      "cursor.autoCompletions" = true;
      "cursor.enableAIFeatures" = true;
      
      # Editor settings optimized for AI workflows
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrains Mono', 'FiraCode Nerd Font', 'Cascadia Code', monospace";
      "editor.fontLigatures" = true;
      "editor.lineHeight" = 1.6;
      "editor.renderWhitespace" = "boundary";
      "editor.cursorBlinking" = "smooth";
      "editor.minimap.enabled" = false;
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
        "source.organizeImports" = "explicit";
      };
      
      # AI-enhanced IntelliSense
      "editor.inlineSuggest.enabled" = true;
      "editor.quickSuggestions" = {
        "other" = "on";
        "comments" = "on";
        "strings" = "on";
      };
      "editor.suggestSelection" = "first";
      "editor.tabCompletion" = "on";
      "editor.wordBasedSuggestions" = "matchingDocuments";
      
      # Terminal and shell integration
      "terminal.integrated.fontFamily" = "'JetBrains Mono', 'FiraCode Nerd Font'";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.lineHeight" = 1.2;
      "terminal.integrated.shell.osx" = lib.mkIf pkgs.stdenv.isDarwin "${pkgs.zsh}/bin/zsh";
      "terminal.integrated.shell.linux" = lib.mkIf pkgs.stdenv.isLinux "${pkgs.zsh}/bin/zsh";
      
      # Git integration
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "git.suggestSmartCommit" = true;
      
      # Language-specific settings
      "rust-analyzer.enable" = true;
      "rust-analyzer.checkOnSave.command" = "clippy";
      "typescript.preferences.quoteStyle" = "single";
      "javascript.preferences.quoteStyle" = "single";
      
      # Workspace settings
      "workbench.colorTheme" = "Dark+ (default dark)";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 20;
      
      # File management
      "files.autoSave" = "onFocusChange";
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.exclude" = {
        "**/.git" = true;
        "**/.svn" = true;
        "**/.hg" = true;
        "**/CVS" = true;
        "**/.DS_Store" = true;
        "**/node_modules" = true;
        "**/target" = true;
        "**/.cargo" = true;
      };
      
      # AI-specific features
      "cursor.chat.enabled" = true;
      "cursor.prediction.enabled" = true;
      "cursor.prediction.delay" = 100;
      
      # Performance settings
      "search.useRipgrep" = true;
      "search.maintainFileSearchCache" = true;
      "typescript.tsc.autoDetect" = "on";
      "extensions.autoUpdate" = false; # Managed by Nix
    };
  };

  # VSCode configuration as backup editor
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # AI and productivity
      github.copilot                 # GitHub Copilot
      github.copilot-chat            # GitHub Copilot Chat
      ms-vscode.vscode-ai            # VS Code AI tools
      
      # Rust development
      rust-lang.rust-analyzer        # Rust analyzer
      tamasfe.even-better-toml       # TOML support
      serayuzgur.crates              # Crates.io integration
      
      # Web development
      bradlc.vscode-tailwindcss      # Tailwind CSS
      ms-vscode.vscode-typescript-next # TypeScript
      
      # General development
      ms-vscode.vscode-json          # JSON support
      redhat.vscode-yaml             # YAML support
      ms-python.python               # Python support
      ms-python.black-formatter      # Black formatter
      
      # Git and version control
      eamodio.gitlens                # Git lens
      mhutchie.git-graph             # Git graph
      
      # Themes and UI
      dracula-theme.theme-dracula    # Dracula theme
      pkief.material-icon-theme      # Material icons
      
      # Utilities
      ms-vscode.hexeditor            # Hex editor
      ms-vscode-remote.remote-ssh    # Remote SSH
      streetsidesoftware.code-spell-checker # Spell checker
    ];
    
    userSettings = {
      # AI settings
      "github.copilot.enable" = true;
      "github.copilot.inlineSuggest.enable" = true;
      "github.copilot.suggestions.enabled" = true;
      
      # Editor configuration
      "editor.fontFamily" = "'JetBrains Mono', 'FiraCode Nerd Font', monospace";
      "editor.fontSize" = 14;
      "editor.lineHeight" = 1.6;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
        "source.organizeImports" = "explicit";
      };
      
      # Terminal
      "terminal.integrated.fontFamily" = "'JetBrains Mono'";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.shell.osx" = lib.mkIf pkgs.stdenv.isDarwin "/bin/zsh";
      "terminal.integrated.shell.linux" = lib.mkIf pkgs.stdenv.isLinux "/bin/zsh";
      
      # Theming
      "workbench.colorTheme" = "Dracula";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      
      # Git
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;
      
      # Language specific
      "rust-analyzer.checkOnSave.command" = "clippy";
      "rust-analyzer.cargo.features" = "all";
      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "editor.formatOnSave" = true;
      };
      
      # Python
      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
        "editor.formatOnSave" = true;
      };
      
      # TypeScript/JavaScript
      "[typescript]" = {
        "editor.defaultFormatter" = "ms-vscode.vscode-typescript-next";
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "ms-vscode.vscode-typescript-next";
      };
      
      # Performance
      "extensions.autoUpdate" = false;
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "none";
    };
  };

  # Helix configuration enhancements for AI workflows
  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus";
      
      editor = {
        line-number = "relative";
        mouse = true;
        middle-click-paste = true;
        scroll-lines = 3;
        shell = [ "zsh" "-c" ];
        file-picker = {
          hidden = false;
        };
        statusline = {
          left = [ "mode" "spinner" ];
          center = [ "file-name" ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
          separator = "│";
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "┊";
          skip-levels = 1;
        };
        gutters = [ "diagnostics" "spacer" "line-numbers" "spacer" "diff" ];
        auto-completion = true;
        auto-format = true;
        auto-save = true;
        idle-timeout = 250;
        completion-timeout = 5;
        preview-completion-insert = true;
        completion-trigger-len = 2;
        auto-info = true;
        true-color = true;
        rulers = [ 80 120 ];
        bufferline = "multiple";
        color-modes = true;
      };
      
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
    
    languages = {
      language = [
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
          auto-format = true;
          formatter = {
            command = "rustfmt";
            args = [ "--edition" "2021" ];
          };
        }
        {
          name = "python";
          language-servers = [ "pylsp" ];
          auto-format = true;
          formatter = {
            command = "black";
            args = [ "-" ];
          };
        }
        {
          name = "javascript";
          language-servers = [ "typescript-language-server" ];
          auto-format = true;
        }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
          auto-format = true;
        }
      ];
    };
  };

  # Shell aliases for AI tools
  programs.zsh.shellAliases = {
    # Cursor aliases
    "cursor" = "code-cursor";
    "c" = "code-cursor .";
    
    # VSCode aliases
    "code" = "code";
    "vc" = "code .";
    
    # Helix aliases
    "hx" = "helix";
    "h" = "helix";
    
    # Claude Code CLI (when available)
    "claude" = "claude-code";
    "ai" = "claude-code";
    
    # Git with AI assistance
    "gai" = "gh copilot suggest";
    "gai-explain" = "gh copilot explain";
  };

  # Environment variables for AI tools
  home.sessionVariables = {
    # Editor preferences
    EDITOR = "helix";
    VISUAL = "code-cursor";
    AI_EDITOR = "code-cursor";
    
    # AI tool configurations
    COPILOT_NODE_PATH = "${pkgs.nodejs_20}/bin/node";
    
    # Python path for AI tools
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH";
  };

  # Install additional AI development tools via home.activation
  home.activation.install-ai-tools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Install GitHub Copilot CLI if available
    if command -v gh >/dev/null 2>&1; then
      echo "Installing GitHub Copilot CLI extensions..."
      $DRY_RUN_CMD gh extension install github/gh-copilot 2>/dev/null || echo "GitHub Copilot CLI already installed or not available"
    fi
    
    # Install Python AI tools
    if command -v pip3 >/dev/null 2>&1; then
      echo "Installing Python AI development tools..."
      $DRY_RUN_CMD pip3 install --user --upgrade \
        openai \
        anthropic \
        langchain \
        jupyter \
        ipython \
        2>/dev/null || echo "Some Python AI tools installation skipped"
    fi
  '';
}