{ config, lib, pkgs, ... }:

{
  # Comprehensive Git configuration for cross-platform development
  # Optimized for modern workflows with AI assistance and team collaboration
  
  home.packages = with pkgs; [
    git                 # Git version control system
    gh                  # GitHub CLI with Copilot integration
    gitui               # Terminal UI for Git (Rust)
    lazygit             # Simple terminal UI for Git (Go)
    git-lfs             # Git Large File Storage
    git-crypt           # Transparent file encryption in Git
    tig                 # Text-based Git repository browser
    gitleaks            # Secrets detection tool
    pre-commit          # Pre-commit hook framework
    commitizen          # Conventional commit tools
    git-absorb          # Automatic fixup commits
    git-branchless      # High-velocity monorepo-scale workflow
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    gitg                # GNOME Git repository viewer
  ];

  # Comprehensive Git configuration
  programs.git = {
    enable = true;
    
    # User configuration - TODO: Make these configurable per machine
    userName = "Jackson Miller";
    userEmail = "jackson@civitas.ltd";
    
    # Git aliases for enhanced productivity
    aliases = {
      # Basic shortcuts
      s = "status";
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      ca = "commit -a";
      cm = "commit -m";
      cam = "commit -am";
      cp = "cherry-pick";
      
      # Advanced shortcuts
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      
      # Logging aliases with improved formatting
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lga = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      lgp = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -p";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      tree = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      
      # Diff aliases
      d = "diff";
      dc = "diff --cached";
      ds = "diff --stat";
      dw = "diff --word-diff";
      
      # Branch management
      recent-branches = "branch --sort=-committerdate";
      rb = "branch --sort=-committerdate";
      branch-cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
      
      # Stash management
      sl = "stash list";
      sp = "stash pop";
      ss = "stash save";
      sa = "stash apply";
      sd = "stash drop";
      
      # Remote management
      rv = "remote -v";
      ra = "remote add";
      rr = "remote rm";
      
      # Workflow shortcuts
      sync = "!git pull origin main && git push origin main";
      update = "!git fetch origin && git rebase origin/main";
      wip = "!git add -A && git commit -m 'WIP: work in progress'";
      unwip = "!git log -n 1 | grep -q -c 'WIP' && git reset HEAD~1";
      
      # Advanced workflows
      standup = "log --since='yesterday' --author='Jackson Miller' --oneline";
      today = "log --since='midnight' --author='Jackson Miller' --oneline";
      week = "log --since='1 week ago' --author='Jackson Miller' --oneline";
      
      # Cleanup and maintenance
      cleanup = "!git branch-cleanup && git remote prune origin && git gc";
      authors = "shortlog -sn";
      contributors = "shortlog -sn";
      
      # AI-assisted development
      ai-commit = "!gh copilot suggest -t shell \"git commit with a good message for: $(git diff --cached --name-only | tr '\n' ' ')\"";
      ai-branch = "!gh copilot suggest -t shell \"create a good git branch name for: $1\"";
      
      # Security and auditing
      audit = "!gitleaks detect --source .";
      secrets = "!gitleaks detect --source .";
      
      # File history and blame
      file-history = "log --follow -p --";
      who = "blame -w -C -C -C";
      
      # Interactive operations
      add-interactive = "add -i";
      rebase-interactive = "rebase -i";
      
      # Conventional commits
      feat = "!git commit -m \"feat: $1\" #";
      fix = "!git commit -m \"fix: $1\" #";
      docs = "!git commit -m \"docs: $1\" #";
      style = "!git commit -m \"style: $1\" #";
      refactor = "!git commit -m \"refactor: $1\" #";
      test = "!git commit -m \"test: $1\" #";
      chore = "!git commit -m \"chore: $1\" #";
    };

    # Advanced Git configuration
    extraConfig = {
      # Core settings
      core = {
        editor = "helix";                    # Use Helix as default editor
        autocrlf = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isDarwin "input")
          (lib.mkIf pkgs.stdenv.isLinux "input")
        ];
        safecrlf = true;                     # Warn about mixed line endings
        filemode = lib.mkIf pkgs.stdenv.isDarwin false; # Ignore file mode changes on macOS
        precomposeUnicode = lib.mkIf pkgs.stdenv.isDarwin true; # Handle Unicode on macOS
        quotepath = false;                   # Don't quote non-ASCII characters
        whitespace = "trailing-space,space-before-tab";
        excludesfile = "${config.home.homeDirectory}/.gitignore_global";
        attributesfile = "${config.home.homeDirectory}/.gitattributes_global";
        hooksPath = "${config.home.homeDirectory}/.git-hooks";
      };
      
      # Branch and initialization
      init = {
        defaultBranch = "main";
      };
      
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
      };
      
      # Pull and merge strategy
      pull = {
        rebase = true;                       # Always rebase on pull
        ff = "only";                         # Fast-forward only
      };
      
      push = {
        default = "simple";                  # Push current branch to upstream
        autoSetupRemote = true;              # Automatically set up remote tracking
        followtags = true;                   # Push tags with commits
      };
      
      # Merge and rebase settings
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";             # Show base in merge conflicts
        ff = false;                          # Always create merge commit
      };
      
      rebase = {
        autoStash = true;                    # Automatically stash before rebase
        autoSquash = true;                   # Automatically squash fixup commits
      };
      
      # Diff settings
      diff = {
        algorithm = "patience";              # Better diff algorithm
        renames = "copies";                  # Detect renames and copies
        mnemonicPrefix = true;               # Use mnemonic prefixes
        compactionHeuristic = true;          # Better diff output
        colorMoved = "default";              # Color moved lines
        tool = "difftastic";                 # Use difftastic for diffs
      };
      
      # Status and logging
      status = {
        showUntrackedFiles = "all";          # Show all untracked files
        submoduleSummary = true;             # Show submodule summary
      };
      
      log = {
        date = "relative";                   # Use relative dates
        decorate = "short";                  # Decorate log output
        follow = true;                       # Follow file renames
      };
      
      # Color configuration
      color = {
        ui = "auto";                         # Enable colors
        branch = "auto";
        diff = "auto";
        status = "auto";
        interactive = "auto";
      };
      
      # GitHub and remote settings
      github = {
        user = "jacksonmiller";              # GitHub username
      };
      
      # URL shortcuts for common repositories
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "https://github.com/" = {
          insteadOf = "github:";
        };
      };
      
      # Credential management
      credential = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin {
          helper = "osxkeychain";            # Use macOS Keychain
        })
        (lib.mkIf pkgs.stdenv.isLinux {
          helper = "store";                  # Use credential store on Linux
        })
      ];
      
      # Security settings
      transfer = {
        fsckobjects = true;                  # Check objects on transfer
      };
      
      fetch = {
        fsckobjects = true;                  # Check objects on fetch
        prune = true;                        # Prune remote tracking branches
      };
      
      receive = {
        fsckObjects = true;                  # Check objects on receive
      };
      
      # Performance settings
      pack = {
        threads = "0";                       # Use all available cores
      };
      
      # Submodule settings
      submodule = {
        recurse = true;                      # Recursively handle submodules
      };
      
      # Large File Storage
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      
      # Web interface
      web = {
        browser = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isDarwin "open")
          (lib.mkIf pkgs.stdenv.isLinux "firefox")
        ];
      };
      
      # Maintenance and optimization
      maintenance = {
        strategy = "incremental";            # Incremental maintenance
      };
      
      # AI and modern tooling integration
      copilot = {
        enable = true;                       # Enable GitHub Copilot CLI integration
      };
      
      # Conventional commits
      commit = {
        template = "${config.home.homeDirectory}/.gitmessage";
        gpgsign = false;                     # Disable GPG signing by default
      };
      
      # Tag settings
      tag = {
        sort = "-version:refname";           # Sort tags by version
      };
      
      # Rerere (reuse recorded resolution)
      rerere = {
        enabled = true;                      # Remember conflict resolutions
        autoUpdate = true;                   # Automatically update index
      };
      
      # Help settings
      help = {
        autocorrect = 1;                     # Auto-correct typos after 1 second
      };
    };

    # Enhanced Delta configuration for better diffs
    delta = {
      enable = true;
      options = {
        # Appearance
        dark = true;
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        hyperlinks = true;
        
        # Syntax highlighting
        syntax-theme = "gruvbox-dark";
        plus-style = "syntax #003800";
        minus-style = "syntax #3f0001";
        
        # Navigation
        navigate-regex = "^(diff|\\*\\*\\*|\\-\\-\\-)";
        
        # File headers
        file-style = "omit";
        hunk-header-decoration-style = "blue box";
        hunk-header-file-style = "red";
        hunk-header-line-number-style = "#067a00";
        hunk-header-style = "file line-number syntax";
        
        # Line numbers
        line-numbers-left-format = "{nm:>4}┊";
        line-numbers-right-format = "{np:>4}│";
        line-numbers-left-style = "blue";
        line-numbers-right-style = "blue";
        
        # Whitespace
        whitespace-error-style = "22 reverse";
        
        # Blame
        blame-code-style = "syntax";
        blame-format = "{author:<18} ({commit:>7}) {timestamp:^16} ";
        blame-palette = "#2E3440 #3B4252 #434C5E #4C566A";
        
        # Interactive features
        hyperlinks-file-link-format = "file://{path}:{line}";
        
        # Performance
        max-line-distance = "0.6";
        max-line-length = "512";
        
        # Features
        features = "side-by-side line-numbers decorations";
        
        # Zero-width characters
        inspect-raw-lines = false;
      };
    };

    # Git ignore patterns
    ignores = [
      # Operating system files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      
      # Editor and IDE files
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".*.sw[a-z]"
      "*.tmp"
      
      # Build artifacts
      "node_modules/"
      "target/"
      "dist/"
      "build/"
      "*.log"
      "*.pid"
      "*.seed"
      "*.pid.lock"
      
      # Environment files
      ".env"
      ".env.local"
      ".env.*.local"
      
      # Cache files
      ".cache/"
      "*.cache"
      ".npm"
      ".yarn/"
      
      # Backup files
      "*.bak"
      "*.backup"
      "*.orig"
      
      # Rust specific
      "Cargo.lock"
      "/target/"
      "**/*.rs.bk"
      
      # Python specific
      "__pycache__/"
      "*.py[cod]"
      "*$py.class"
      "*.so"
      ".Python"
      "pip-log.txt"
      "pip-delete-this-directory.txt"
      
      # Node.js specific
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      
      # Personal files
      "TODO.txt"
      "NOTES.txt"
      "*.private"
    ];
  };

  # Additional Git configuration files
  home.file = {
    # Global gitignore
    ".gitignore_global".text = ''
      # macOS
      .DS_Store
      .AppleDouble
      .LSOverride
      Icon
      ._*
      .DocumentRevisions-V100
      .fseventsd
      .Spotlight-V100
      .TemporaryItems
      .Trashes
      .VolumeIcon.icns
      .com.apple.timemachine.donotpresent
      .AppleDB
      .AppleDesktop
      Network Trash Folder
      Temporary Items
      .apdisk

      # Windows
      Thumbs.db
      Thumbs.db:encryptable
      ehthumbs.db
      ehthumbs_vista.db
      *.tmp
      *.temp
      *.lnk
      Desktop.ini
      $RECYCLE.BIN/
      *.cab
      *.msi
      *.msix
      *.msm
      *.msp
      *.lnk

      # Linux
      *~
      .fuse_hidden*
      .directory
      .Trash-*
      .nfs*

      # Editors
      .vscode/
      .idea/
      *.swp
      *.swo
      *~
      .*.sw[a-z]
      *.tmp
      .vim/
      .netrwhist

      # Build artifacts
      node_modules/
      target/
      dist/
      build/
      out/
      .next/
      .nuxt/
      .cache/

      # Environment and secrets
      .env
      .env.local
      .env.*.local
      *.key
      *.pem
      *.p12
      *.cert
      *.crt
      secrets.txt
      config.json
      
      # Logs
      *.log
      logs/
      
      # Databases
      *.db
      *.sqlite
      *.sqlite3
      
      # Archives
      *.zip
      *.tar.gz
      *.rar
      *.7z
      
      # Personal notes
      TODO.txt
      NOTES.txt
      *.private
      scratch.*
    '';

    # Git attributes for better handling of different file types
    ".gitattributes_global".text = ''
      # Handle line endings automatically for files detected as text
      * text=auto

      # Explicitly declare text files you want to always be normalized and converted
      # to native line endings on checkout.
      *.c text
      *.h text
      *.rs text
      *.py text
      *.js text
      *.ts text
      *.jsx text
      *.tsx text
      *.html text
      *.css text
      *.scss text
      *.sass text
      *.json text
      *.xml text
      *.yml text
      *.yaml text
      *.toml text
      *.md text
      *.txt text
      *.sh text eol=lf
      *.zsh text eol=lf
      *.bash text eol=lf
      *.fish text eol=lf

      # Declare files that will always have CRLF line endings on checkout.
      *.bat text eol=crlf
      *.cmd text eol=crlf
      *.ps1 text eol=crlf

      # Denote all files that are truly binary and should not be modified.
      *.png binary
      *.jpg binary
      *.jpeg binary
      *.gif binary
      *.ico binary
      *.mov binary
      *.mp4 binary
      *.mp3 binary
      *.flv binary
      *.fla binary
      *.swf binary
      *.gz binary
      *.zip binary
      *.7z binary
      *.ttf binary
      *.eot binary
      *.woff binary
      *.woff2 binary
      *.exe binary
      *.dll binary
      *.so binary
      *.dylib binary
      *.pdf binary
      *.doc binary
      *.docx binary
      *.xls binary
      *.xlsx binary
      *.ppt binary
      *.pptx binary

      # Language-specific settings
      *.rs diff=rust
      *.py diff=python
      *.js diff=javascript
      *.ts diff=typescript
      *.go diff=golang
      
      # Large files that should use Git LFS
      *.psd filter=lfs diff=lfs merge=lfs -text
      *.ai filter=lfs diff=lfs merge=lfs -text
      *.sketch filter=lfs diff=lfs merge=lfs -text
      *.fig filter=lfs diff=lfs merge=lfs -text
      *.mp4 filter=lfs diff=lfs merge=lfs -text
      *.mov filter=lfs diff=lfs merge=lfs -text
      *.avi filter=lfs diff=lfs merge=lfs -text
      *.mkv filter=lfs diff=lfs merge=lfs -text
      *.zip filter=lfs diff=lfs merge=lfs -text
      *.tar.gz filter=lfs diff=lfs merge=lfs -text
      *.iso filter=lfs diff=lfs merge=lfs -text
      *.dmg filter=lfs diff=lfs merge=lfs -text
    '';

    # Commit message template
    ".gitmessage".text = ''
      # <type>(<scope>): <subject>
      #
      # <body>
      #
      # <footer>
      
      # Type should be one of the following:
      # * feat: A new feature
      # * fix: A bug fix
      # * docs: Documentation only changes
      # * style: Changes that do not affect the meaning of the code
      # * refactor: A code change that neither fixes a bug nor adds a feature
      # * perf: A code change that improves performance
      # * test: Adding missing tests or correcting existing tests
      # * build: Changes that affect the build system or external dependencies
      # * ci: Changes to our CI configuration files and scripts
      # * chore: Other changes that don't modify src or test files
      # * revert: Reverts a previous commit
      #
      # Scope is optional and should be the name of the package affected
      #
      # Subject line should be no longer than 50 characters
      # Body should be wrapped at 72 characters
      # Use the body to explain what and why vs. how
    '';
  };

  # Shell aliases for Git workflows
  programs.zsh.shellAliases = {
    # Basic Git commands
    "ga" = "git add";
    "gaa" = "git add --all";
    "gc" = "git commit";
    "gcm" = "git commit -m";
    "gca" = "git commit --amend";
    "gco" = "git checkout";
    "gb" = "git branch";
    "gp" = "git push";
    "gpl" = "git pull";
    "gf" = "git fetch";
    "gd" = "git diff";
    "gdc" = "git diff --cached";
    "gla" = "git log --oneline --all -10";
    
    # Advanced Git workflows
    "gstash" = "git stash";
    "gpop" = "git stash pop";
    "greset" = "git reset --hard";
    "gclean" = "git clean -fd";
    "grebase" = "git rebase -i";
    "gmerge" = "git merge --no-ff";
    
    # Git with UI
    "gitui" = "gitui";
    "lazy" = "lazygit";
    "tig" = "tig";
    
    # GitHub CLI
    "ghpr" = "gh pr create";
    "ghprs" = "gh pr status";
    "ghprv" = "gh pr view";
    "ghprc" = "gh pr checkout";
    "ghissue" = "gh issue create";
    "ghissues" = "gh issue list";
    
    # Project shortcuts
    "clone" = "git clone";
    "init" = "git init";
    "remote" = "git remote -v";
    
    # Conventional commits
    "feat" = "git commit -m 'feat: ";
    "fix" = "git commit -m 'fix: ";
    "docs" = "git commit -m 'docs: ";
    "chore" = "git commit -m 'chore: ";
    
    # Quick operations
    "gitignore" = "curl -s https://www.gitignore.io/api/";
    "wip" = "git add -A && git commit -m 'WIP: work in progress'";
    "save" = "git add -A && git commit -m 'SAVEPOINT'";
    "undo" = "git reset HEAD~1 --mixed";
    "amend" = "git commit -a --amend";
    "today" = "git log --since='midnight' --author='Jackson Miller' --oneline";
  };

  # Environment variables for Git
  home.sessionVariables = {
    # Git configuration
    GIT_EDITOR = "helix";
    GIT_PAGER = "delta";
    
    # GitHub CLI
    GITHUB_TOKEN_FILE = "${config.home.homeDirectory}/.github-token";
    
    # Git performance
    GIT_OPTIONAL_LOCKS = "0";  # Disable optional locks for performance
  };

  # Git hooks directory setup
  home.activation.setupGitHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create git hooks directory
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.git-hooks"
    
    # Create a sample pre-commit hook
    $DRY_RUN_CMD cat > "${config.home.homeDirectory}/.git-hooks/pre-commit" << 'EOF'
#!/bin/bash
# Sample pre-commit hook that runs basic checks

# Check for secrets
if command -v gitleaks >/dev/null 2>&1; then
    gitleaks protect --staged --redact
fi

# Run pre-commit if available
if command -v pre-commit >/dev/null 2>&1; then
    pre-commit run --all-files
fi
EOF
    
    $DRY_RUN_CMD chmod +x "${config.home.homeDirectory}/.git-hooks/pre-commit"
  '';
} 