{ config, lib, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.emacs-macport else pkgs.emacs;  # Platform-specific Emacs
  };

  # Install Doom Emacs and required packages
  home.packages = with pkgs; [
    # Doom Emacs dependencies
    git
    ripgrep
    fd
    
    # Email
    mu
    isync # mbsync
    
    # Build tools
    gnumake
    cmake
    
    # Core programming language support
    ## Rust
    # rustup removed to avoid collision with rust-analyzer
    
    ## Python
    python3
    
    ## Go
    go
    
    # Markdown/Org support
    pandoc
    
    # Version control
    git
    
    # Fuzzy finding
    fzf
    
    # Text processing
    aspell
    aspellDicts.en
    
    # File navigation/search
    silver-searcher
    
    # JSON tools
    jq
  ];

  # Set up the doom emacs installation - manual step
  # Note: Due to activation issues, please run these commands manually after installation:
  #   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
  #   ~/.emacs.d/bin/doom install --no-config --no-env --no-fonts

  # Create necessary Doom Emacs configuration files
  home.file = {
    # Doom init.el - configure which modules to load
    ".doom.d/init.el".text = ''
      ;;; init.el -*- lexical-binding: t; -*-

      (doom! :input
             :completion
             (company +childframe)    ; the ultimate code completion backend
             (vertico +icons)          ; the search engine of the future

             :ui
             doom                      ; what makes DOOM look the way it does
             doom-dashboard            ; a nifty splash screen for Emacs
             doom-quit                 ; DOOM quit-message prompts when you quit Emacs
             (emoji +unicode)          ; 🙂
             hl-todo                   ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
             hydra
             indent-guides             ; highlighted indent columns
             ligatures                 ; ligatures and symbols to make code pretty again
             minimap                   ; show a map of the code on the side
             modeline                  ; snazzy, Atom-inspired modeline, plus API
             nav-flash                 ; blink cursor line after big motions
             ophints                   ; highlight the region an operation acts on
             (popup +defaults)         ; tame sudden yet inevitable temporary windows
             tabs                      ; a tab bar for Emacs
             treemacs                  ; a project drawer, like neotree but cooler
             unicode                   ; extended unicode support for various languages
             vc-gutter                 ; vcs diff in the fringe
             vi-tilde-fringe           ; fringe tildes to mark beyond EOB
             window-select             ; visually switch windows
             workspaces                ; tab emulation, persistence & separate workspaces
             zen                       ; distraction-free coding or writing

             :editor
             (evil +everywhere)        ; come to the dark side, we have cookies
             file-templates            ; auto-snippets for empty files
             fold                      ; (nigh) universal code folding
             (format +onsave)          ; automated prettiness
             multiple-cursors          ; editing in many places at once
             snippets                  ; my elves. They type so I don't have to
             word-wrap                 ; soft wrapping with language-aware indent

             :emacs
             dired                     ; making dired pretty [functional]
             electric                  ; smarter, keyword-based electric-indent
             ibuffer                   ; interactive buffer management
             undo                      ; persistent, smarter undo for your inevitable mistakes
             vc                        ; version-control and Emacs, sitting in a tree

             :term
             eshell                    ; the elisp shell that works everywhere
             shell                     ; simple shell REPL for Emacs
             term                      ; basic terminal emulator for Emacs
             vterm                     ; the best terminal emulation in Emacs

             :checkers
             syntax                    ; tasing you for every semicolon you forget
             (spell +flyspell)         ; tasing you for misspelling mispelling
             grammar                   ; tasing grammar mistake every you make

             :tools
             (debugger +lsp)           ; FIXME stepping through code, to help you add bugs
             direnv                    ; be direct about your environment
             docker                    ; port everything to containers
             editorconfig              ; let someone else argue about tabs vs spaces
             (eval +overlay)           ; run code, run (also, repls)
             gist                      ; interacting with github gists
             (lookup +dictionary       ; navigate code and documentation
                     +docsets)
             (lsp +peek)               ; M-x vscode
             (magit +forge)            ; a git porcelain for Emacs
             make                      ; run make tasks from Emacs
             pdf                       ; pdf enhancements
             prodigy                   ; FIXME managing external services & code builders
             rgb                       ; creating color strings
             taskrunner                ; taskrunner for all your projects
             terraform                 ; infrastructure as code
             tmux                      ; an API for interacting with tmux
             tree-sitter               ; syntax and parsing, sitting in a tree...
             upload                    ; map local to remote projects via ssh/ftp

             :os
             ,(if (string-equal system-type "darwin") 'macos 'linux) ; OS-specific commands
             tty                       ; improve the terminal Emacs experience

             :lang
             (cc +lsp)                 ; C > C++ == 1
             data                      ; config/data formats
             emacs-lisp                ; drown in parentheses
             (go +lsp)                 ; the hipster dialect
             (json +lsp)               ; At least it ain't XML
             (javascript +lsp)         ; all(hope(abandon(ye(who(enter(here))))))
             (markdown +grip)          ; writing docs for people to ignore
             (org +dragndrop           ; organize your plain life in plain text
                  +hugo
                  +journal
                  +pandoc
                  +present
                  +roam2)
             (mu4e +org +gmail)         ; email in emacs
             (python +lsp              ; beautiful is better than ugly
                     +pyright
                     +poetry)
             (rust +lsp)               ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
             (sh +lsp)                 ; she sells {ba,z,fi}sh shells on the C xor
             (web +lsp)                ; the tubes
             (yaml +lsp)               ; JSON, but readable

             :config
             (default +bindings +smartparens))
    '';

    # Doom config.el - user configuration
    ".doom.d/config.el".text = ''
      ;;; config.el -*- lexical-binding: t; -*-

      ;; Personal Information
      (setq user-full-name "Jackson Miller"
            user-mail-address "jackson@civitas.ltd")

      ;; Theme Setup
      (setq doom-theme 'doom-one)

      ;; Font Configuration - platform specific
      (setq doom-font (font-spec :family "JetBrains Mono" :size 14)
            doom-variable-pitch-font (font-spec :family "Overpass" :size 14)
            doom-big-font (font-spec :family "JetBrains Mono" :size 24))

      ;; Line Numbers
      (setq display-line-numbers-type 'relative)

      ;; Maximize Frame on Startup
      (add-to-list 'initial-frame-alist '(fullscreen . maximized))

      ;; Org Mode Configuration
      (setq org-directory "~/org/")

      ;; Projectile Configuration
      (setq projectile-project-search-path '("~/Projects/"))

      ;; LSP configuration
      (after! lsp-mode
        (setq lsp-rust-analyzer-server-display-inlay-hints t
              lsp-rust-analyzer-display-chaining-hints t
              lsp-rust-analyzer-display-parameter-hints t
              lsp-ui-doc-enable t
              lsp-ui-doc-show-with-cursor t))

      ;; Python Configuration
      (after! python
        (setq python-shell-interpreter "python3"))

      ;; Configure automatic linting and formatting 
      (add-hook! 'python-mode-hook #'python-black-on-save-mode)

      ;; Enhanced Search Configuration
      (after! ivy
        (setq ivy-use-virtual-buffers t
              ivy-count-format "(%d/%d) "
              ivy-initial-inputs-alist nil))
      
      ;; Better Treemacs Integration
      (after! treemacs
        (setq treemacs-width 30
              treemacs-position 'left
              treemacs-git-mode 'deferred))
              
      ;; Org-Roam Configuration 
      (after! org-roam 
        (setq org-roam-directory "~/org/roam"))
        
      ;; Email Configuration (mu4e)
      (after! mu4e
        ;; Set up Gmail integration
        (setq mu4e-get-mail-command "mbsync -a"
              mu4e-update-interval 300
              mu4e-compose-signature-auto-include t
              mu4e-view-show-images t
              mu4e-view-show-addresses t
              mu4e-attachment-dir "~/Downloads"
              mu4e-maildir "~/.mail"
              mu4e-contexts
              `(,(make-mu4e-context
                  :name "work"
                  :match-func (lambda (msg)
                                (when msg
                                  (string-prefix-p "/jackson-civitas" (mu4e-message-field msg :maildir))))
                  :vars '((user-mail-address . "jackson@civitas.ltd")
                          (user-full-name . "Jackson Miller")
                          (mu4e-compose-signature . "Jackson Miller\nCivitas Ltd.")
                          (mu4e-drafts-folder . "/jackson-civitas/[Gmail]/Drafts")
                          (mu4e-sent-folder . "/jackson-civitas/[Gmail]/Sent Mail")
                          (mu4e-trash-folder . "/jackson-civitas/[Gmail]/Trash")
                          (mu4e-refile-folder . "/jackson-civitas/[Gmail]/All Mail")))))

        ;; Configure Gmail-specific settings
        (setq message-send-mail-function 'smtpmail-send-it
              smtpmail-stream-type 'starttls
              smtpmail-default-smtp-server "smtp.gmail.com"
              smtpmail-smtp-server "smtp.gmail.com"
              smtpmail-smtp-service 587))
    '';

    # Doom packages.el - additional packages to install
    ".doom.d/packages.el".text = ''
      ;; -*- no-byte-compile: t; -*-
      ;;; packages.el

      ;; Additional packages not in Doom modules
      
      ;; Enhanced search and replace
      (package! deadgrep)          ; ripgrep front-end
      (package! wgrep)             ; edit grep buffers
      
      ;; Git extensions
      (package! git-link)          ; get GitHub/GitLab etc links for files
      (package! git-timemachine)   ; walk through git history
      (package! gist)              ; interact with gist.github.com
      
      ;; Productivity 
      (package! focus)             ; dim surrounding text
      (package! command-log-mode)  ; log commands to a buffer
      
      ;; Programming helpers
      (package! format-all)        ; universal formatter
      (package! mermaid-mode)      ; diagrams as code
      (package! graphql-mode)      ; GraphQL support
      (package! lsp-pyright)       ; Python LSP
      (package! python-black)      ; Python formatter
      (package! flutter)           ; Flutter development
      (package! dart-mode)         ; Dart language support
      
      ;; Note taking
      (package! org-super-agenda)  ; filter and group org agenda items
    '';

    # Create mbsync config file for Gmail
    ".mbsyncrc".text = ''
      # Gmail account
      IMAPAccount jackson-civitas
      Host imap.gmail.com
      User jackson@civitas.ltd
      # Platform-specific password command
      PassCmd "${if pkgs.stdenv.isDarwin then
                 "security find-generic-password -s 'mbsync-gmail-jackson-civitas' -w"
               else
                 "pass show email/jackson@civitas.ltd"
               }"
      Port 993
      SSLType IMAPS
      CertificateFile ${if pkgs.stdenv.isDarwin then
                         "/etc/ssl/cert.pem"
                       else
                         "/etc/ssl/certs/ca-certificates.crt"
                       }

      # Remote storage
      IMAPStore jackson-civitas-remote
      Account jackson-civitas

      # Local storage
      MaildirStore jackson-civitas-local
      Subfolders Verbatim
      Path ~/.mail/jackson-civitas/
      Inbox ~/.mail/jackson-civitas/Inbox

      # Connections between remote and local
      Channel jackson-civitas
      Far :jackson-civitas-remote:
      Near :jackson-civitas-local:
      Patterns *
      Create Both
      SyncState *
      Expunge Both
    '';
  };
}