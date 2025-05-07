# Neovim Configuration (NixVim)

This is a comprehensive Neovim configuration managed through NixVim and Home Manager. It's designed to provide a modern, IDE-like experience with support for multiple languages, sleek UI, and productivity-enhancing features.

## Features

### Core Features
- 🎨 **Tokyo Night** colorscheme with proper styling
- 🔍 **Telescope** for fuzzy finding files, text, and more
- 🌳 **Nvim-tree** for file navigation
- 🧠 **LSP Integration** for code intelligence
- 📝 **Completion** with nvim-cmp and luasnip
- 🔄 **Git Integration** with Gitsigns, Diffview, and Neogit
- 📊 **Statusline** with Lualine and buffer tabs with Bufferline
- 🖼️ **UI Enhancements** with Tree-sitter, indent guides, and more
- 📁 **Project Navigation** with Harpoon
- 🔤 **Auto-pairs** for brackets and quotes
- 💻 **Terminal Integration** with Toggleterm
- 📚 **Which-key** for keybinding help

### Language Support
- TypeScript/JavaScript
- Python
- Rust
- Go
- HTML/CSS
- JSON/YAML
- Nix
- Lua
- Bash
- Docker

## Key Mappings

### General
- `<Space>` - Leader key
- `<Leader>w` - Save file
- `<C-h/j/k/l>` - Navigate between windows
- `<C-Up/Down/Left/Right>` - Resize windows

### File Navigation
- `<Leader>e` - Toggle file explorer
- `<Leader>o` - Focus file explorer
- `<Leader>ff` - Find files
- `<Leader>fg` - Live grep (search text)
- `<Leader>fb` - Find buffers
- `<Leader>fh` - Find help tags
- `<Leader>fs` - Find string under cursor
- `<Leader>fo` - Find recent files

### Code Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Go to references
- `K` - Show hover documentation
- `<Leader>rn` - Rename symbol
- `<Leader>ca` - Code actions
- `<Leader>f` - Format code
- `<Leader>lf` - Format with LSP
- `<Leader>d` - Show diagnostics
- `[d/]d` - Previous/next diagnostic

### Harpoon
- `<Leader>a` - Add file to harpoon
- `<Leader>h` - Toggle harpoon menu
- `<Leader>1-4` - Jump to harpoon marks 1-4

### Git
- `<Leader>gg` - Open Neogit

### Buffer Management
- `<S-h/l>` - Previous/next buffer
- `<Leader>q` - Close buffer without closing window

### Terminal
- `<C-\>` - Toggle terminal
- `<Esc>` or `jk` in terminal - Exit terminal mode
- Terminal window navigation with `<C-h/j/k/l>`

### Folding (with UFO)
- `zR` - Open all folds
- `zM` - Close all folds

## Customization

To customize this setup:

1. Edit the `neovim.nix` file
2. Run the rebuild command: `nixrebuild`

## Tips

- Use which-key to discover keybindings by pressing `<Leader>` and waiting
- For large codebases, use Telescope grep (`<Leader>fg`) for search
- Harpoon is extremely useful for quickly jumping between your most-used files
- Toggle term's float mode works well for quick commands (use `<C-\>`)
- Use Neogit (`<Leader>gg`) for a magit-like Git experience

## Troubleshooting

If you experience any issues:

1. Check the LSP status with `:LspInfo`
2. Verify treesitter parsers with `:TSInstallInfo`
3. Look for errors with `:checkhealth`