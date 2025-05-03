{ config, lib, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    
    config = {
      # ---------- Global options ----------
      globals = {
        mapleader = " ";  # Use space as the leader key
        maplocalleader = ",";
      };

      # Core editor options
      options = {
      # Display line numbers
      number = true;  
      relativenumber = true;

      # Tab settings
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      # Search settings
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      
      # Modern UI elements
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      colorcolumn = "80";
      
      # Better scrolling
      scrolloff = 8;
      sidescrolloff = 8;
      
      # Splitting
      splitright = true;
      splitbelow = true;
      
      # File handling
      swapfile = false;
      backup = false;
      undofile = true;
      undodir = "~/.config/nvim/undodir";
      
      # Completion
      completeopt = ["menuone" "noselect" "noinsert"];
      
      # Miscellaneous
      hidden = true;
      updatetime = 100;
      timeoutlen = 500;
    };
    
      # Core Keymappings
      keymaps = [
        # Quick save
        { 
          mode = "n"; 
          key = "<leader>w"; 
          action = ":w<CR>"; 
          options.desc = "Save file"; 
        }
        
        # Better window navigation
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Navigate to left window";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Navigate to bottom window";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Navigate to top window";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Navigate to right window";
        }
        
        # Resize windows
        {
          mode = "n";
          key = "<C-Up>";
          action = ":resize +2<CR>";
          options.desc = "Increase window height";
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = ":resize -2<CR>";
          options.desc = "Decrease window height";
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = ":vertical resize -2<CR>";
          options.desc = "Decrease window width";
        }
        {
          mode = "n";
          key = "<C-Right>";
          action = ":vertical resize +2<CR>";
          options.desc = "Increase window width";
        }
        
        # Better indenting
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Indent left and keep selection";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Indent right and keep selection";
        }
        
        # Move highlighted text
        {
          mode = "v";
          key = "J";
          action = ":m '>+1<CR>gv=gv";
          options.desc = "Move text down";
        }
        {
          mode = "v";
          key = "K";
          action = ":m '<-2<CR>gv=gv";
          options.desc = "Move text up";
        }
        
        # Keep cursor centered during search and joining
        {
          mode = "n";
          key = "n";
          action = "nzzzv";
          options.desc = "Next search result (centered)";
        }
        {
          mode = "n";
          key = "N";
          action = "Nzzzv";
          options.desc = "Previous search result (centered)";
        }
        {
          mode = "n";
          key = "J";
          action = "mzJ`z";
          options.desc = "Join lines (keep cursor position)";
        }
        
        # Clear search highlight
        {
          mode = "n";
          key = "<Esc>";
          action = ":noh<CR>";
          options.desc = "Clear search highlight";
        }
      ];

      # ---------- Colorscheme ----------
      colorschemes.tokyonight = {
        enable = true;
        style = "storm"; # Options: night, storm, day, moon
        transparent = false;
        styles = {
          comments = { italic = true; };
          keywords = { italic = true; };
          functions = { bold = true; };
          variables = {};
        };
      };

      # ---------- UI Enhancements ----------
      plugins = {
      # Native LSP setup
      lsp = {
        enable = true;
        servers = {
          # Web/JS/TS Development
          tsserver.enable = true;
          eslint.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          
          # Python
          pyright.enable = true;
          
          # Rust
          rust-analyzer = {
            enable = true;
            settings.check.command = "clippy";
          };
          
          # Go
          gopls.enable = true;
          
          # Common
          lua-ls.enable = true;
          nixd.enable = true;
          bashls.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
        };
        
        keymaps = {
          diagnostic = {
            # Navigate diagnostics
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            # LSP actions
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "gr" = "references";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "<leader>f" = "format";
          };
        };
      };
      
      # Autocomplete
      nvim-cmp = {
        enable = true;
        snippet.expand = "luasnip";
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                  require('luasnip').expand_or_jump()
                else
                  fallback()
                end
              end
            '';
            modes = [ "i" "s" ];
          };
          "<S-Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require('luasnip').jumpable(-1) then
                  require('luasnip').jump(-1)
                else
                  fallback()
                end
              end
            '';
            modes = [ "i" "s" ];
          };
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
      };
      
      # Snippets
      luasnip.enable = true;
      
      # Treesitter for better syntax highlighting
      treesitter = {
        enable = true;
        ensureInstalled = [
          "lua"
          "rust"
          "toml"
          "typescript"
          "javascript"
          "tsx"
          "json"
          "yaml"
          "html"
          "css"
          "bash"
          "python"
          "go"
          "gomod"
          "nix"
          "markdown"
          "markdown_inline"
          "regex"
          "vim"
          "vimdoc"
        ];
        incrementalSelection = {
          enable = true;
          keymaps = {
            initSelection = "<CR>";
            nodeIncremental = "<CR>";
            nodeDecremental = "<BS>";
            scopeIncremental = "<TAB>";
          };
        };
        indent.enable = true;
      };
      
      # File explorer
      nvim-tree = {
        enable = true;
        openOnSetup = false;
        autoClose = true;
        diagnostics.enable = true;
        hijackCursor = true;
        updateFocusedFile.enable = true;
        gitIntegration.enable = true;
        view = {
          number = false;
          relativenumber = false;
          width = 30;
        };
      };
      
      # Status line
      lualine = {
        enable = true;
        iconsEnabled = true;
        theme = "tokyonight";
        componentSeparators = {
          left = "";
          right = "";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
      };
      
      # Add buffer line for better buffer navigation
      bufferline = {
        enable = true;
        diagnostics = "nvim_lsp";
        separatorStyle = "slant";
        closeIcon = "";
      };
      
      # Telescope (fuzzy finder)
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fs" = "grep_string";
          "<leader>fo" = "oldfiles";
        };
      };
      
      # Better comment support
      comment-nvim.enable = true;
      
      # Indent guides
      indent-blankline.enable = true;
      
      # Git integration
      gitsigns = {
        enable = true;
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
        };
      };
      
      # Diffview for better merge conflict resolution
      diffview.enable = true;
      
      # Git UI
      neogit = {
        enable = true;
        integrations.diffview = true;
      };
      
      # Auto-pairs for brackets, quotes, etc.
      nvim-autopairs.enable = true;
      
      # Buffer deletion without closing windows
      bufdelete.enable = true;
      
      # Harpoon for quick file navigation
      harpoon = {
        enable = true;
        keymaps = {
          addFile = "<leader>a";
          toggleQuickMenu = "<leader>h";
          navFile = {
            "1" = "<leader>1";
            "2" = "<leader>2";
            "3" = "<leader>3";
            "4" = "<leader>4";
          };
        };
      };
      
      # Which-key for keybinding help
      which-key.enable = true;
      
      # Terminal integration
      toggleterm = {
        enable = true;
        direction = "float";
        openMapping = "<C-\\>";
        shell = "zsh";
        size = 20;
        floatOpts = {
          border = "curved";
        };
      };
      
      # Better folding
      nvim-ufo.enable = true;
    };
    
      # ---------- Custom vim commands ----------
      extraConfigLua = ''
        -- Terminal-specific keymaps
        function _G.set_terminal_keymaps()
          local opts = {buffer = 0}
          vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end

        -- Run terminal keymaps when opening terminal
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

        -- Additional nvim-tree keymaps
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {silent = true})
        vim.keymap.set('n', '<leader>o', ':NvimTreeFocus<CR>', {silent = true})

        -- Bufferline keymaps
        vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>', {silent = true})
        vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>', {silent = true})
        vim.keymap.set('n', '<leader>q', ':Bdelete<CR>', {silent = true})
        
        -- Neogit keymap
        vim.keymap.set('n', '<leader>gg', ':Neogit<CR>', {silent = true})
        
        -- LSP Format keymap
        vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, {silent = true})
        
        -- Diagnostics keymaps
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {silent = true})
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {silent = true})
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {silent = true})
        
        -- UFO folding setup
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        
        -- Per-buffer LSP attach handler
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            -- Enable inlay hints for supported languages
            if client and client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end
          end
        })
      '';
    }; # End of config section
  };
}