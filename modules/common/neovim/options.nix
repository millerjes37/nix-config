# modules/common/neovim/options.nix
{ lib, pkgs, ... }:
{
  # This file configures basic Neovim options.
  # For more details on these options, see :help <option-name> in Neovim.

  extraConfig = ''
    " -----------------------------------------------------------------------------
    " Basic Editor Settings
    " -----------------------------------------------------------------------------
    set number                      " Show line numbers
    set relativenumber              " Show relative line numbers
    set cursorline                  " Highlight the current line
    set scrolloff=8                 " Keep 8 lines visible above/below cursor when scrolling
    set sidescrolloff=8             " Keep 8 columns visible left/right of cursor when scrolling
    set mouse=a                     " Enable mouse support in all modes
    set clipboard=unnamedplus       " Use system clipboard for copy/paste

    " Indentation
    set expandtab                   " Use spaces instead of tabs
    set tabstop=2                   " Number of visual spaces per tab
    set shiftwidth=2                " Number of spaces for autoindent
    set softtabstop=2               " Number of spaces for tab key
    set autoindent                  " Copy indent from current line when starting a new line
    set smartindent                 " Smarter autoindenting for C-like languages

    " Search
    set ignorecase                  " Ignore case when searching
    set smartcase                   " Override ignorecase if search pattern contains uppercase letters
    set incsearch                   " Show search results incrementally
    set hlsearch                    " Highlight all search matches

    " Performance and Behavior
    set termguicolors               " Enable true color support in the terminal
    set updatetime=250              " Faster update time for CursorHold events (e.g., GitGutter)
    set signcolumn=yes              " Always show the sign column to prevent jitter
    set completeopt=menu,menuone,noselect " Completion options

    " UI
    set background=dark             " Assume a dark background for syntax highlighting
                                    " Theme will be set in plugins.nix or a dedicated theme file
    
    " Folding (basic, can be enhanced with plugins)
    " set foldmethod=indent           " Fold based on indent
    " set foldlevelstart=99           " Start with all folds open

    " Backup and Swap files (consider your preference)
    set nobackup                    " Do not create backup files
    set nowritebackup               " Only if 'backup' is set
    set noswapfile                  " Do not create swap files

    " Spell checking (disabled by default, can be enabled with :set spell)
    set nospell

    " More friendly command line
    set cmdheight=1                 " Only one line for commands unless needed
    set laststatus=2                " Always show status line

    " Wild menu completion
    set wildmenu                    " Enable command-line completion wildmenu
    set wildmode=longest:full,full  " Completion mode

    " Better scrolling
    set smoothscroll                " Enable smooth scrolling (Neovim 0.9+)

    " Show matching parentheses
    set showmatch

    " Title
    set title                       " Set terminal title to filename
    set titlestring=%t              " Format of the title string (filename only)

    " No annoying sound on errors
    set visualbell
    set noerrorbells
  '';
}
