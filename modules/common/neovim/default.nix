{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Basic plugins
    plugins = with pkgs.vimPlugins; [
      # UI
      gruvbox
      vim-airline
      vim-airline-themes
      nvim-web-devicons
      
      # Git integration
      vim-fugitive
      vim-gitgutter
      
      # Navigation and utilities
      telescope-nvim
      vim-easymotion
      nvim-tree-lua
      
      # Syntax and languages
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      
      # Snippets support
      luasnip
      cmp_luasnip
    ];

    # Basic configuration
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set cursorline
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set autoindent
      set smartindent
      set ignorecase
      set smartcase
      set scrolloff=5
      set mouse=a
      set termguicolors
      set updatetime=250
      set background=dark
      set clipboard=unnamedplus
      
      " Theme
      colorscheme gruvbox
      
      " Key mappings
      let mapleader = " "

      " Navigate buffers
      nnoremap <leader>bn :bnext<CR>
      nnoremap <leader>bp :bprevious<CR>
      nnoremap <leader>bd :bdelete<CR>
      
      " File operations
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>wq :wq<CR>
      nnoremap <leader>e :NvimTreeToggle<CR>
      
      " Search with Telescope
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    '';

    # Lua config for advanced plugins
    extraLuaConfig = ''
      -- Treesitter configuration
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      }
      
      -- LSP configuration
      local lspconfig = require('lspconfig')
      
      -- Set up various language servers
      local servers = { 'pyright', 'rust_analyzer', 'tsserver', 'gopls' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {}
      end
      
      -- Completion setup
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
      
      -- NvimTree setup
      require('nvim-tree').setup()
      
      -- Setup telescope
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
        }
      }
    '';
  };

  # Install LSP servers and other tools
  home.packages = with pkgs; [
    # Language servers
    nodePackages.typescript-language-server
    gopls
    rust-analyzer
    
    # Formatting tools
    nodePackages.prettier
    python311Packages.black
    
    # Linters
    nodePackages.eslint
    
    # Other tools
    ripgrep    # Required for Telescope live grep
    fd         # Better find for Telescope
  ];
}