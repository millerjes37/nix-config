# modules/common/neovim/lua-config.nix
{ lib, pkgs, ... }:
{
  # This file contains Lua configurations for Neovim plugins.
  programs.neovim.extraLuaConfig = ''
    -- -----------------------------------------------------------------------------
    -- Utility functions
    -- -----------------------------------------------------------------------------
    local function map(mode, lhs, rhs, opts)
      local options = { noremap=true, silent=true }
      if opts then options = vim.tbl_extend('force', options, opts) end
      vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end

    -- -----------------------------------------------------------------------------
    -- Plugin: nvim-treesitter
    -- -----------------------------------------------------------------------------
    require'nvim-treesitter.configs'.setup {
      ensure_installed = "all",
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    }

    -- -----------------------------------------------------------------------------
    -- Plugin: nvim-lspconfig
    -- -----------------------------------------------------------------------------
    local lspconfig = require('lspconfig')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

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
      map('n', '<leader>de', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopts) -- Changed from <leader>e to avoid conflict
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

    local servers = { 'pyright', 'rust_analyzer', 'tsserver', 'gopls', 'nil_ls', 'bashls', 'dockerls', 'jsonls', 'yamlls' }
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
    end

    -- -----------------------------------------------------------------------------
    -- Plugin: nvim-cmp (Autocompletion)
    -- -----------------------------------------------------------------------------
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    cmp.setup({
      snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
          else fallback() end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then luasnip.jump(-1)
          else fallback() end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'buffer' }, { name = 'path' },
      }),
      experimental = { ghost_text = true }
    })

    -- -----------------------------------------------------------------------------
    -- Plugin: nvim-tree (File Explorer)
    -- -----------------------------------------------------------------------------
    require('nvim-tree').setup({
      sort_by = "case_sensitive",
      view = { width = 30, side = 'left' },
      renderer = {
        group_empty = true, highlight_git = true,
        icons = {
          show = { file = true, folder = true, folder_arrow = true, git = true },
          glyphs = {
            default = "", symlink = "",
            folder = { arrow_closed = "", arrow_open = "", default = "", open = "", empty = "", empty_open = "", symlink = "", symlink_open = "" },
            git = { unstaged = "✗", staged = "✓", unmerged = "", renamed = "➜", untracked = "★", deleted = "", ignored = "◌" },
          },
        },
      },
      filters = { dotfiles = false, custom = { ".git", "node_modules", ".cache" } },
      git = { enable = true, ignore = false, timeout = 400 },
      actions = { open_file = { quit_on_open = false, resize_window = true } }
    })

    -- -----------------------------------------------------------------------------
    -- Plugin: telescope (Fuzzy Finder)
    -- -----------------------------------------------------------------------------
    local telescope = require('telescope')
    telescope.setup {
      defaults = {
        prompt_prefix = " ", selection_caret = " ", path_display = { "truncate" },
        file_ignore_patterns = { "node_modules", ".git", "target", ".mypy_cache", "__pycache__", ".DS_Store", "%.ipynb" },
        mappings = {
          i = { ["<C-j>"] = require('telescope.actions').move_selection_next, ["<C-k>"] = require('telescope.actions').move_selection_previous, ["<C-q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist, ["<esc>"] = require('telescope.actions').close },
          n = { ["<C-j>"] = require('telescope.actions').move_selection_next, ["<C-k>"] = require('telescope.actions').move_selection_previous, ["<C-q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist },
        }
      },
      pickers = {
        find_files = { theme = "dropdown", previewer = true, hidden = true },
        live_grep = { theme = "dropdown", previewer = true },
        buffers = { theme = "dropdown", previewer = true, sort_mru = true, ignore_current_buffer = true },
        help_tags = { theme = "dropdown", previewer = true },
        oldfiles = { theme = "dropdown", previewer = true }
      },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" }
      }
    }
    -- pcall(telescope.load_extension, "fzf") -- Uncomment if you add telescope-fzf-native to plugins

    -- -----------------------------------------------------------------------------
    -- Custom Macros
    -- -----------------------------------------------------------------------------
    -- Define custom macros here. Macros are sequences of commands that can be
    -- recorded and played back. You can define them as Lua functions and map them,
    -- or set register contents directly.
    --
    -- Example 1: Simple macro to insert a boilerplate text using vim.fn.setreg
    -- vim.fn.setreg('m', 'This is my boilerplate text!\\<Esc>0', 'c') -- Sets register 'm'
    -- You can then run this macro with "@m" in normal mode.
    -- The '\\<Esc>0' moves to the beginning of the line after insertion.
    -- 'c' means characterwise sequence. Use 'l' for linewise, 'b' for blockwise.

    -- Example 2: A Lua function mapped to a key as a macro-like utility
    -- local function MyTimestampMacro()
    --   local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    --   vim.api.nvim_put({timestamp}, 'c', true, true)
    -- end
    -- vim.keymap.set('n', '<leader>mt', MyTimestampMacro, {noremap = true, silent = true, desc = "Insert Timestamp"})

    -- To add your own macros:
    -- 1. Record a macro: Start recording by typing `q` followed by a letter (e.g., `qa`).
    --    Perform your actions, then press `q` again to stop recording.
    -- 2. Get the macro content: Type `:reg a` (if you saved to register 'a') to see its content.
    -- 3. Define it in Lua:
    --    Use `vim.fn.setreg('a', 'your-macro-content-here', 'c')`
    --    Remember to escape special characters like <CR> as \\<CR>, <Esc> as \\<Esc>, etc. (Note: double backslash for Nix string)
    --    Or, translate the logic into a Lua function if it's more complex.
    -- 4. If you defined a Lua function, you might want to map it to a key using
    --    `vim.keymap.set('n', '<leader>mykey', YourLuaFunction, {desc = "My custom macro"})`
    --    Place these definitions within this Lua configuration block.

    -- Placeholder for user-defined macros:
    -- vim.fn.setreg('q', 'iHello NixVim User!\\<Esc>', 'c') -- Example: content for register q
    -- vim.api.nvim_set_keymap('n', '<leader>mq', '@q', { noremap = true, silent = true, desc = "Run macro q" })
  '';
}
