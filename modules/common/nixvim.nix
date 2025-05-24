# modules/common/nixvim.nix
{ config, lib, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    # Later, we will add plugins, options, keymaps, luaConfig here.
    plugins = {
      # UI & Appearance
      airline.enable = true;
      airline-themes.enable = true;
      nvim-web-devicons.enable = true; # Usually a dependency, but good to be explicit
      lspkind.enable = true; # onsails_lspkind-nvim

      # Git Integration
      fugitive.enable = true;
      gitgutter.enable = true;

      # Navigation & Utilities
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true; # telescope-fzf-native-nvim
        };
      };
      # nvim-tree = {
      #  enable = true;
        # luaSetup = true; # Implied by nixvim structure, customize later if needed
      #};

      # Editing Enhancements
      comment.enable = true; # numToStr_Comment-nvim
      autopairs.enable = true; # windwp_nvim-autopairs

      # Syntax, Highlighting & Language Support
      treesitter
      cmp = {
        enable = true; # nvim-cmp
        sources = [
          { name = "nvim_lsp"; } # cmp-nvim-lsp
          { name = "buffer"; }   # cmp-buffer
          { name = "path"; }     # cmp-path
          { name = "luasnip"; }  # cmp_luasnip
        ];
      };

      # Snippets
      luasnip.enable = true;
      friendly-snippets.enable = true; # rafamadriz_friendly-snippets

      # Colorscheme
      gruvbox.enable = true;
    };

    # Options
    opts = {
      # Basic Editor Settings
      number = true;                      # Show line numbers
      relativenumber = true;              # Show relative line numbers
      cursorline = true;                  # Highlight the current line
      scrolloff = 8;                 # Keep 8 lines visible above/below cursor when scrolling
      sidescrolloff = 8;             # Keep 8 columns visible left/right of cursor when scrolling
      mouse = "a";                     # Enable mouse support in all modes
      clipboard = "unnamedplus";       # Use system clipboard for copy/paste

      # Indentation
      expandtab = true;                   # Use spaces instead of tabs
      tabstop = 2;                   # Number of visual spaces per tab
      shiftwidth = 2;                # Number of spaces for autoindent
      softtabstop = 2;               # Number of spaces for tab key
      autoindent = true;                  # Copy indent from current line when starting a new line
      smartindent = true;                 # Smarter autoindenting for C-like languages

      # Search
      ignorecase = true;                  # Ignore case when searching
      smartcase = true;                   # Override ignorecase if search pattern contains uppercase letters
      incsearch = true;                   # Show search results incrementally
      hlsearch = true;                    # Highlight all search matches

      # Performance and Behavior
      termguicolors = true;               # Enable true color support in the terminal
      updatetime = 250;              # Faster update time for CursorHold events (e.g., GitGutter)
      signcolumn = "yes";              # Always show the sign column to prevent jitter
      completeopt = "menu,menuone,noselect"; # Completion options

      # UI
      # background = "dark"; # Handled by colorscheme setting below

      # Folding (basic, can be enhanced with plugins)
      # foldmethod = "indent";           # Fold based on indent - consider nixvim.plugins.fold-cycle or similar
      # foldlevelstart = 99;           # Start with all folds open

      # Backup and Swap files (consider your preference)
      backup = false;                    # Do not create backup files
      writebackup = false;               # Only if 'backup' is set
      swapfile = false;                  # Do not create swap files

      # Spell checking (disabled by default, can be enabled with :set spell)
      spell = false;

      # More friendly command line
      cmdheight = 1;                 # Only one line for commands unless needed
      laststatus = 2;                # Always show status line

      # Wild menu completion
      wildmenu = true;                    # Enable command-line completion wildmenu
      wildmode = "longest:full,full";  # Completion mode

      # Better scrolling
      smoothscroll = true;                # Enable smooth scrolling (Neovim 0.9+)

      # Show matching parentheses
      showmatch = true;

      # Title
      title = true;                       # Set terminal title to filename
      titlestring = "%t";              # Format of the title string (filename only)

      # No annoying sound on errors
      visualbell = true;
      errorbells = false;
    };

    # Colorscheme
    colorscheme = "gruvbox"; # This assumes gruvbox plugin handles 'set background=dark' or it's the default.
                             # If not, might need: colorscheme.settings.background = "dark";

    # Global variables (like mapleader)
    globals = {
      mapleader = " ";
      maplocalleader = "\\"; # Note: in Nix strings, backslash needs to be escaped.
    };

    # Keymaps
    keymaps = [
      # General & Navigation
      { key = "<leader>w"; action = ":w<CR>"; mode = "n"; }
      { key = "<leader>w"; action = "<C-C>:w<CR>"; mode = "v"; } # Original was <C-C>:w<CR> - need to ensure this works as intended.
      { key = "<C-s>"; action = "<Esc>:w<CR>a"; mode = "i"; }

      { key = "<leader>q"; action = ":q<CR>"; mode = "n"; }
      { key = "<leader>Q"; action = ":qa!<CR>"; mode = "n"; }
      { key = "<leader>wq"; action = ":wq<CR>"; mode = "n"; }

      { key = "<leader>bd"; action = ":bdelete<CR>"; mode = "n"; }
      { key = "<leader>bD"; action = ":bdelete!<CR>"; mode = "n"; }

      { key = "<leader>bn"; action = ":bnext<CR>"; mode = "n"; }
      { key = "<leader>bp"; action = ":bprevious<CR>"; mode = "n"; }
      { key = "<S-L>"; action = ":bnext<CR>"; mode = "n"; }
      { key = "<S-H>"; action = ":bprevious<CR>"; mode = "n"; }
      { key = "<leader>bl"; action = ":ls<CR>"; mode = "n"; }

      { key = "<C-h>"; action = "<C-w>h"; mode = "n"; }
      { key = "<C-j>"; action = "<C-w>j"; mode = "n"; }
      { key = "<C-k>"; action = "<C-w>k"; mode = "n"; }
      { key = "<C-l>"; action = "<C-w>l"; mode = "n"; }

      { key = "<leader>sv"; action = ":vsplit<CR>"; mode = "n"; }
      { key = "<leader>sH"; action = ":split<CR>"; mode = "n"; } # Renamed from sh
      { key = "<leader>sc"; action = "<C-w>c"; mode = "n"; }
      { key = "<leader>so"; action = "<C-w>o"; mode = "n"; } # Close other windows

      { key = "<leader>="; action = "<C-w>="; mode = "n"; } # Equalize window sizes
      { key = "<leader>+"; action = ":resize +2<CR>"; mode = "n"; }
      { key = "<leader>-"; action = ":resize -2<CR>"; mode = "n"; }
      { key = "<leader>>"; action = ":vertical resize +2<CR>"; mode = "n"; }
      { key = "<leader><"; action = ":vertical resize -2<CR>"; mode = "n"; }

      { key = "<leader>tn"; action = ":tabnew<CR>"; mode = "n"; }
      { key = "<leader>tc"; action = ":tabclose<CR>"; mode = "n"; }
      { key = "<leader>to"; action = ":tabonly<CR>"; mode = "n"; }
      { key = "<leader>tl"; action = ":tabnext<CR>"; mode = "n"; }
      { key = "<leader>th"; action = ":tabprevious<CR>"; mode = "n"; }
      { key = "<leader>t<Space>"; action = ":tabs<CR>"; mode = "n"; }

      # Editing Enhancements
      { key = "J"; action = ":m '>+1<CR>gv=gv"; mode = "v"; }
      { key = "K"; action = ":m '<-2<CR>gv=gv"; mode = "v"; }
      { key = "<"; action = "<gv"; mode = "v"; }
      { key = ">"; action = ">gv"; mode = "v"; }
      { key = "<leader><space>"; action = ":noh<CR>"; mode = "n"; }
      { key = "<leader>x"; action = "<cmd>!chmod +x %<CR><CR>"; mode = "n"; } # Should be fine
      { key = "<leader>so"; action = "<cmd>so %<CR>"; mode = "n"; } # Note: this conflicts with <leader>so for close other windows. Will resolve later if necessary. For now, using the one from keymaps.nix.

      # Terminal Mappings
      { key = "<leader>ft"; action = "<cmd>split term://zsh<CR><C-w>j:resize 15<CR>i"; mode = "n"; }
      { key = "<leader>fT"; action = "<cmd>vsplit term://zsh<CR>i"; mode = "n"; }
      { key = "<Esc>"; action = "<C-\\><C-n>"; mode = "t"; }
      { key = "<C-v><Esc>"; action = "<Esc>"; mode = "t"; } # Send literal Esc
      { key = "<C-w>h"; action = "<C-\\><C-N><C-w>h"; mode = "t"; }
      { key = "<C-w>j"; action = "<C-\\><C-N><C-w>j"; mode = "t"; }
      { key = "<C-w>k"; action = "<C-\\><C-N><C-w>k"; mode = "t"; }
      { key = "<C-w>l"; action = "<C-\\><C-N><C-w>l"; mode = "t"; }

      # Plugin: NvimTree
      { key = "<leader>e"; action = ":NvimTreeToggle<CR>"; mode = "n"; }
      { key = "<leader>fe"; action = ":NvimTreeFindFile<CR>"; mode = "n"; }

      # Plugin: Telescope
      { key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; mode = "n"; }
      { key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; mode = "n"; }
      { key = "<leader>fG"; action = "<cmd>Telescope grep_string<cr>"; mode = "n"; }
      { key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; mode = "n"; }
      { key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; mode = "n"; }
      { key = "<leader>fo"; action = "<cmd>Telescope oldfiles<cr>"; mode = "n"; }
      { key = "<leader>fz"; action = "<cmd>Telescope current_buffer_fuzzy_find<cr>"; mode = "n"; }
      { key = "<leader>flr"; action = "<cmd>Telescope lsp_references<cr>"; mode = "n"; }
      { key = "<leader>fld"; action = "<cmd>Telescope lsp_definitions<cr>"; mode = "n"; }
      { key = "<leader>fli"; action = "<cmd>Telescope lsp_implementations<cr>"; mode = "n"; }
      { key = "<leader>fls"; action = "<cmd>Telescope lsp_document_symbols<cr>"; mode = "n"; }
      { key = "<leader>flS"; action = "<cmd>Telescope lsp_workspace_symbols<cr>"; mode = "n"; }
      { key = "<leader>fk"; action = "<cmd>Telescope keymaps<cr>"; mode = "n"; }
      { key = "<leader>fco"; action = "<cmd>Telescope commands<cr>"; mode = "n"; }
      { key = "<leader>fC"; action = "<cmd>Telescope colorscheme<cr>"; mode = "n"; }
      { key = "<leader>fm"; action = "<cmd>Telescope marks<cr>"; mode = "n"; }
      { key = "<leader>fR"; action = "<cmd>Telescope registers<cr>"; mode = "n"; }
      { key = "<leader>fgb"; action = "<cmd>Telescope git_branches<cr>"; mode = "n"; }
      { key = "<leader>fgc"; action = "<cmd>Telescope git_commits<cr>"; mode = "n"; }
      { key = "<leader>fgB"; action = "<cmd>Telescope git_bcommits<cr>"; mode = "n"; }
      { key = "<leader>fgs"; action = "<cmd>Telescope git_status<cr>"; mode = "n"; }

      # Plugin: Fugitive
      { key = "<leader>gs"; action = "<cmd>Git<CR>"; mode = "n"; }
      { key = "<leader>gc"; action = "<cmd>Git commit<CR>"; mode = "n"; }
      { key = "<leader>gp"; action = "<cmd>Git push<CR>"; mode = "n"; }
      { key = "<leader>gP"; action = "<cmd>Git pull<CR>"; mode = "n"; }
      { key = "<leader>gb"; action = "<cmd>Git blame<CR>"; mode = "n"; }
      { key = "<leader>gd"; action = "<cmd>Gvdiffsplit<CR>"; mode = "n"; }
      { key = "<leader>gh"; action = "<cmd>diffget //2<CR>"; mode = "n"; } # fugitive uses :diffget //2
      { key = "<leader>gu"; action = "<cmd>diffget //3<CR>"; mode = "n"; } # fugitive uses :diffget //3
      { key = "<leader>gA"; action = "<cmd>Git add %<CR>"; mode = "n"; }
      { key = "<leader>ga"; action = "<cmd>Git add .<CR>"; mode = "n"; }
      { key = "<leader>gr"; action = "<cmd>Git restore %<CR>"; mode = "n"; }
      { key = "<leader>gR"; action = "<cmd>Git restore .<CR>"; mode = "n"; }

      # Plugin: Comment.nvim
      # For Comment.nvim, the action might be better handled via its nixvim plugin options if available,
      # otherwise, a Lua action might be needed. The original was: vnoremap <leader>/ <cmd>CommentToggle<CR>gv
      # This translates to a command for visual mode.
      { key = "<leader>/"; action = "<cmd>CommentToggle<CR>gv"; mode = "v"; lua = false; } # Explicitly not Lua

      # LSP (Language Server Protocol)
      { key = "<leader>lf"; action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>"; mode = "n"; }

      # Quickfix & Location List Navigation
      { key = "<leader>co"; action = ":copen<CR>"; mode = "n"; }
      { key = "<leader>cc"; action = ":cclose<CR>"; mode = "n"; }
      { key = "<leader>cn"; action = ":cnext<CR>"; mode = "n"; }
      { key = "<leader>cp"; action = ":cprevious<CR>"; mode = "n"; }
      { key = "<leader>cf"; action = ":cfirst<CR>"; mode = "n"; }
      { key = "<leader>cl"; action = ":clast<CR>"; mode = "n"; }

      { key = "<leader>lo"; action = ":lopen<CR>"; mode = "n"; }
      { key = "<leader>lc"; action = ":lclose<CR>"; mode = "n"; }
      { key = "<leader>ln"; action = ":lnext<CR>"; mode = "n"; }
      { key = "<leader>lp"; action = ":lprevious<CR>"; mode = "n"; }
      { key = "<leader>lL"; action = ":lfirst<CR>"; mode = "n"; } # Renamed from lf
      { key = "<leader>ll"; action = ":llast<CR>"; mode = "n"; }

      # Spelling
      { key = "<leader>sp"; action = "<cmd>set spell!<CR>"; mode = "n"; }
      { key = "<leader>s?"; action = "]s"; mode = "n"; }
      { key = "<leader>s!"; action = "[s"; mode = "n"; }
      { key = "<leader>sa"; action = "z="; mode = "n"; }
    ];

    # Lua Configuration
    extraLuaConfig = ''
      -- Utility functions
      local function map(mode, lhs, rhs, opts)
        local options = { noremap=true, silent=true }
        if opts then options = vim.tbl_extend('force', options, opts) end
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
      end

      -- LSP on_attach function
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', bufopts)
        map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', bufopts)
        map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopts)
        map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopts)
        map('n', '<leader>sh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
        map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', bufopts)
        map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', bufopts)
        map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', bufopts)
        map('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', bufopts)
        map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)
        map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', bufopts)
        map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopts)
        map('n', '<leader>de', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopts) -- Changed from <leader>e
        map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', bufopts)
        map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', bufopts)
        map('n', '<leader>dl', '<cmd>lua vim.diagnostic.setloclist()<CR>', bufopts) -- Changed from <leader>q

        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {clear = true}),
            buffer = bufnr,
            callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end,
          })
        end
      end

      -- Setup LSP servers
      local lspconfig = require('lspconfig')
      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local servers = { 'pyright', 'rust_analyzer', 'tsserver', 'gopls', 'nil_ls', 'bashls', 'dockerls', 'jsonls', 'yamlls' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- Custom Macros Placeholder (from lua-config.nix)
      -- vim.fn.setreg('q', 'iHello NixVim User!\\<Esc>', 'c')
      -- vim.api.nvim_set_keymap('n', '<leader>mq', '@q', { noremap = true, silent = true, desc = "Run macro q" })
    '';

    # Plugin-specific Lua configurations (will attempt to move from extraLuaConfig if nixvim provides cleaner options)
    plugins = {
      # ... existing plugins ...
      treesitter = {
        enable = true;
        grammars = "all";
        settings = {
          ensure_installed = "all"; # from lua-config
          sync_install = false;
          auto_install = true;
          highlight = true;
          indent = true;
        };
      };

      cmp = {
        # enable = true;
        sources = [
          { name = "nvim_lsp"; } 
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
        settings = {
          snippet = { expand = "function(args) require('luasnip').lsp_expand(args.body) end"; }; # Added trailing semicolon for consistency
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            # For the multi-line strings, ensure the key is also a string:
            "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif require('luasnip').expand_or_jumpable() then require('luasnip').expand_or_jump() else fallback() end end, { 'i', 's' })";
            "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif require('luasnip').jumpable(-1) then require('luasnip').jump(-1) else fallback() end end, { 'i', 's' })";
          };
          sources = [ # Corrected: Use square brackets for a list
            { name = "nvim_lsp"; }  # Use double quotes for consistency in Nix strings
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ]; # Semicolon to terminate the 'sources' attribute definition
          experimental = { ghost_text = true; }; # Added trailing semicolon for consistency
        };
      };

      nvim-tree = {
        enable = true;
        settings = { # from lua-config
          sort_by = "case_sensitive";
          view = { width = 30; side = "left"; }; 
          renderer = {
            group_empty = true; 
            highlight_git = true;
            icons = {
              show = { 
                file = true;
                folder = true;
                folder_arrow = true;
                git = true;
              };
              glyphs = {
                default = "";
                symlink = "";
                folder = { 
                  arrow_closed = "";
                  arrow_open = "";
                  default = "";
                  open = "";
                  empty = "";
                  empty_open = "";
                  symlink = "";
                  symlink_open = "";
                };
                git = { 
                  unstaged = "✗";
                  staged = "✓";
                  unmerged = "";
                  renamed = "➜";
                  untracked = "★";
                  deleted = "";
                  ignored = "◌"; 
                };
              };
            };
          };
          filters = { 
            dotfiles = false;
            custom = [ ".git" "node_modules" ".cache" ];
          git = { 
            enable = true;
            ignore = false;
            timeout = 400;
          };
          actions = {
            open_file = {
               quit_on_open = false;
              resize_window = true;
            };
          };
        };
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
        settings = { # from lua-config
          defaults = {
            prompt_prefix = " ";
            selection_caret = " ";
            # path_display was changed to a string in your diff.
            # If telescope expects a list (e.g., for multiple formatters),
            # it should be path_display = [ "truncate" ];
            # If a single string is fine, then this is okay.
            path_display = "truncate"; 
            file_ignore_patterns = [ "node_modules" ".git" "target" ".mypy_cache" "__pycache__" ".DS_Store" "%.ipynb" ]; # Correct list format
            mappings = {
              i = {
                "<C-j>" = "require('telescope.actions').move_selection_next";
                "<C-k>" = "require('telescope.actions').move_selection_previous";
                "<C-q>" = "function() require('telescope.actions').send_to_qflist() require('telescope.actions').open_qflist() end";
                "<esc>" = "require('telescope.actions').close";
              };
              n = {
                "<C-j>" = "require('telescope.actions').move_selection_next";
                "<C-k>" = "require('telescope.actions').move_selection_previous";
                "<C-q>" = "function() require('telescope.actions').send_to_qflist() require('telescope.actions').open_qflist() end";
                # Note: Your 'n' mappings in the error output didn't have an <esc> mapping.
                # Add it here if it was intended, for example:
                # "<esc>" = "require('telescope.actions').close"; 
              };
            }; # End of mappings
          }; # End of defaults
          pickers = {
            find_files = {
              theme = "dropdown";
              previewer = true;
              hidden = true;
            };
            live_grep = {
              theme = "dropdown";
              previewer = true;
            };
            buffers = {
              theme = "dropdown";
              previewer = true;
              sort_mru = true;
              ignore_current_buffer = true;
            };
            help_tags = {
              theme = "dropdown";
              previewer = true;
            };
            oldfiles = {
              theme = "dropdown"; 
              previewer = true; # Ensured space for readability
            };
          }; # End of pickers
          extensions = {
            fzf = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
              case_mode = "smart_case";
            };
          }; # End of extensions
          # pcall(telescope.load_extension, "fzf") # This should be handled by nixvim if fzf-native is enabled
        }; # End of settings
      }; # End of telescope
      };
    };
  };
}
