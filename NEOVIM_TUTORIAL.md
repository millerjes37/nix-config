# Neovim Setup Guide & Tutorial (NixVim Edition)

## 1. Introduction

Welcome to your Neovim setup, declaratively managed by Nix and Home Manager! This configuration aims to provide a modern, efficient, and highly customizable Neovim experience.

**Philosophy:**
*   **Declarative:** Your entire Neovim setup (plugins, settings, keymaps) is defined in Nix code.
*   **Reproducible:** Get the exact same Neovim environment on any machine running Nix.
*   **Powerful & Ergonomic:** Leverages modern Neovim features and plugins for a great editing experience.

This guide will walk you through:
*   Understanding your Neovim environment.
*   A VimTutor-style workflow tutorial to get you productive quickly.
*   Detailed references for keybindings and plugins.
*   How to customize and extend your setup.

## 2. Installation & Setup

This Neovim configuration is managed as part of your Home Manager setup.

*   **Activation:** When you run `home-manager switch`, your Neovim configuration is automatically built and made available.
*   **Updates:** To update Neovim, its plugins, or the configuration itself:
    1.  Modify the Nix files (primarily in `~/.config/home-manager/modules/common/neovim/` or wherever your Nix config is structured - adjust this path if your user's setup is different, e.g., directly in the repo).
    2.  Run `home-manager switch` to apply the changes.
    3.  If you update Nix channels (e.g., `nix-channel --update` followed by `home-manager switch`), plugins sourced from `pkgs.vimPlugins` might also get updated to their newer versions available in the updated channels.

## 3. Core Neovim Concepts

If you're new to Vim/Neovim, here are some basics:

*   **Modal Editing:** Neovim has different modes for different tasks.
    *   **Normal Mode:** Default mode for navigation, running commands, manipulating text. Press `<Esc>` to return here.
    *   **Insert Mode:** For typing text. Enter with `i`, `a`, `o`, etc.
    *   **Visual Mode:** For selecting text. Enter with `v` (character-wise), `V` (line-wise), `Ctrl-v` (block-wise).
    *   **Command-line Mode:** For typing commands. Enter with `:` (e.g., `:w` to save).
*   **The Leader Key:** Many custom shortcuts use a "leader" key. **Your leader key is `Space`**.
    *   For example, `<leader>w` means press `Space` then `w`.
*   **Local Leader Key:** Some mappings might use a local leader, which is `\` (backslash).
*   **Basic Survival:**
    *   `:w` - Save the current file.
    *   `:q` - Quit.
    *   `:wq` - Save and quit.
    *   `:q!` - Quit without saving.
    *   `<Esc>` - Return to Normal mode.

## 4. Getting Started: A Workflow Tutorial

This section provides a hands-on tutorial. Try these commands in Neovim!

### Lesson 1: Opening Files & Basic Navigation

1.  **Open Neovim:** Type `nvim` in your terminal.
2.  **Open a file:**
    *   From your terminal: `nvim path/to/your/file.txt`
    *   From within Neovim: `:e path/to/your/file.txt<Enter>`
3.  **Basic Navigation (Normal Mode):**
    *   `h`: Move left
    *   `j`: Move down
    *   `k`: Move up
    *   `l`: Move right
    *   `w`: Move to the start of the next word.
    *   `b`: Move to the start of the previous word.
    *   `0`: Move to the beginning of the line.
    *   `$`: Move to the end of the line.
    *   `gg`: Go to the first line of the file.
    *   `G`: Go to the last line of the file.
    *   `Ctrl-u`: Scroll up half a page.
    *   `Ctrl-d`: Scroll down half a page.
4.  **Simple Edits:**
    *   Move your cursor over a character.
    *   Press `x` to delete the character under the cursor.
    *   Press `i` to enter Insert mode. Type some text.
    *   Press `<Esc>` to return to Normal mode.
    *   Press `u` to undo the last change. `Ctrl-r` to redo.
5.  **Saving and Quitting:**
    *   `<leader>w` (Space then w): Save the file.
    *   `<leader>q` (Space then q): Quit the current file/buffer.
    *   `<leader>wq` (Space then w then q): Save and quit.

### Lesson 2: Using the File Explorer (NvimTree)

NvimTree is your file explorer.

1.  **Toggle NvimTree:** Press `<leader>e` (Space then e).
    *   The file tree appears on the left.
2.  **Navigate NvimTree:**
    *   Use `j` and `k` to move up and down.
    *   Press `Enter` on a directory to expand or collapse it.
    *   Press `Enter` on a file to open it in a new buffer.
    *   `o` also opens, but can be configured for different behaviors (e.g. split).
    *   `-`: Go to parent directory.
    *   `Ctrl-w h` or `Ctrl-l`: Switch focus between NvimTree and your file buffers.
3.  **File Operations in NvimTree (cursor on a file/dir):**
    *   `a`: Add a new file/directory.
    *   `d`: Delete a file/directory (with confirmation).
    *   `r`: Rename a file/directory.
    *   `x`: Cut.
    *   `c`: Copy.
    *   `p`: Paste.
    *   `gy`: Copy path to system clipboard.
4.  **Find Current File:** If you have a file open, press `<leader>fe` to reveal and focus it in NvimTree.
5.  **Close NvimTree:** Press `<leader>e` again, or `q` while NvimTree is focused.

### Lesson 3: Finding Things with Telescope

Telescope is your powerful fuzzy finder.

1.  **Find Files:** Press `<leader>ff` (Space, f, f).
    *   Start typing parts of a filename. Telescope will show matching files in your project.
    *   Use `Ctrl-j` / `Ctrl-k` (or arrow keys) to navigate the results.
    *   Press `Enter` to open the selected file.
    *   Press `<Esc>` to close Telescope.
2.  **Live Grep (Search for text in project):** Press `<leader>fg` (Space, f, g).
    *   Type the text you want to search for. Results update live.
    *   Navigate and open as with Find Files.
3.  **Search for String Under Cursor:** With your cursor on a word, press `<leader>fG`. Telescope will search for that word in the project.
4.  **Find Open Buffers:** Press `<leader>fb` (Space, f, b).
    *   Quickly switch between files you have open.
5.  **Find Help Tags:** Press `<leader>fh` (Space, f, h).
    *   Search Neovim's help documentation (e.g., type `options` or `mapleader`).
6.  **Other useful Telescope searches (explore these!):**
    *   `<leader>fo`: Old files (recently opened).
    *   `<leader>fz`: Fuzzy find within the current buffer.
    *   `<leader>fk`: Keymaps (search available keybindings).
    *   `<leader>fco`: Commands (search Neovim commands).
    *   `<leader>fC`: Colorschemes.
    *   `<leader>fm`: Marks.
    *   `<leader>fR`: Registers.
    *   Git pickers: `<leader>fgb` (branches), `<leader>fgc` (commits), `<leader>fgs` (status).

### Lesson 4: Working with Git (Fugitive & Telescope)

Fugitive provides deep Git integration.

1.  **Git Status:** Press `<leader>gs` (Space, g, s).
    *   This opens a Git status window.
    *   On a file:
        *   `s`: Stage the file/hunk.
        *   `u`: Unstage the file/hunk.
        *   `c`: Commit staged changes.
        *   `dd` or `D`: View diff. Press `dq` to close diff.
        *   `=`: Toggle inline diff.
    *   Press `g?` in the status window for more fugitive help.
2.  **Commit:**
    *   Stage changes via the status window (`<leader>gs` then `s` on files).
    *   Press `<leader>gc` (Space, g, c) or `c` in the status window. This opens a commit message buffer.
    *   Type your commit message. Save and close the buffer (`:wq`) to make the commit.
3.  **Push/Pull:**
    *   `<leader>gp` (Space, g, p): Push changes.
    *   `<leader>gP` (Space, g, Shift-P): Pull changes.
4.  **Blame:** Press `<leader>gb` (Space, g, b) to see `git blame` for the current file. Press `q` in the blame sidebar to close it.
5.  **Diffing:**
    *   `<leader>gd`: View changes to the current file (`Gvdiffsplit`).
    *   Use `]c` and `[c` to jump between hunks.
    *   To get changes from one side to another:
        *   `dp` ("diff put") from the current buffer to the other.
        *   `do` ("diff obtain") from the other buffer to the current.
        *   Or use `<leader>gh` (diffget HEAD) / `<leader>gu` (diffget original/index) in the diff view.
    *   Close diff with `:q` in one of the split windows, or `:only` to keep only one.
6.  **Telescope Git Pickers:**
    *   `<leader>fgb`: View and checkout Git branches.
    *   `<leader>fgc`: Browse Git commits.
    *   `<leader>fgB`: Browse Git commits for the current buffer.
    *   `<leader>fgs`: Browse Git status (alternative to Fugitive's status window).

### Lesson 5: Understanding LSP Features

LSP (Language Server Protocol) provides IDE-like features.

1.  **Autocompletion:** As you type, `nvim-cmp` will show completion suggestions from the LSP and other sources (snippets, buffer words).
    *   Use `Tab` / `S-Tab` or `Ctrl-n` / `Ctrl-p` to navigate suggestions.
    *   Press `Enter` to accept a suggestion.
    *   `Ctrl-Space` can also trigger completions.
2.  **Diagnostics (Errors/Warnings):**
    *   LSPs provide real-time diagnostics. You'll see icons or highlights on lines with issues.
    *   `<leader>de` (Space, d, e): Show diagnostic details for the line under the cursor in a floating window.
    *   `[d`: Go to the previous diagnostic in the buffer.
    *   `]d`: Go to the next diagnostic.
    *   `<leader>dl` (Space, d, l): List all diagnostics in the location list. Use `<leader>lo` to open it if it doesn't open automatically.
3.  **Go to Definition/References etc.:** (These are buffer-local, an LSP must be active for the current filetype)
    *   `gd`: Go to definition of the symbol under the cursor.
    *   `gi`: Go to implementation.
    *   `gD`: Go to declaration.
    *   `K` (Shift-k): Show hover documentation for the symbol under the cursor.
    *   `<leader>rn`: Rename symbol under cursor.
    *   `<leader>ca`: Code actions (e.g., auto-imports, quick fixes).
    *   **Using Telescope for LSP:**
        *   `<leader>flr`: Find LSP references.
        *   `<leader>fld`: Find LSP definitions.
        *   `<leader>fli`: Find LSP implementations.
        *   `<leader>fls`: Document symbols.
        *   `<leader>flS`: Workspace symbols.
4.  **Formatting:** Code is automatically formatted on save if a formatter is configured for the filetype.
    *   You can also manually format with `<leader>lf` (Space, l, f).

### Lesson 6: Editing Efficiently

1.  **Commenting:** (Uses Comment.nvim)
    *   `gcc`: Toggle comment for the current line.
    *   `gc` + motion (e.g., `gcG` to comment to end of file, `gc2j` to comment current and next 2 lines).
    *   In Visual Mode (`v` or `V`), select lines, then press `<leader>/` to toggle comments.
2.  **Auto Pairs:** (Uses nvim-autopairs)
    *   When you type `(`, `[`, `{`, or `"`, the closing pair is automatically inserted.
3.  **Snippets:** (Uses Luasnip and friendly-snippets)
    *   When you type a snippet trigger (e.g., `for` in some languages) and it appears in the completion menu, selecting it will expand the snippet.
    *   If a snippet is active, you can often jump between placeholders using `Tab` (or `Ctrl-j` if configured, check cmp setup in `lua-config`).
    *   Explore available snippets by typing common keywords for your language.
4.  **Moving Lines (Visual Mode):** Select lines with `V`, then:
    *   `J`: Move selected lines down.
    *   `K`: Move selected lines up.
5.  **Indenting (Visual Mode):** Select lines, then:
    *   `>`: Indent selected lines.
    *   `<`: Un-indent.

### Lesson 7: Managing Windows and Tabs

1.  **Windows (Splits):**
    *   `<leader>sv`: Split window vertically.
    *   `<leader>sH`: Split window horizontally.
    *   `Ctrl-w h/j/k/l`: Move cursor to window left/down/up/right.
    *   `<leader>sc` or `Ctrl-w c`: Close current window.
    *   `<leader>so` or `Ctrl-w o`: Close all other windows.
    *   `<leader>=`: Equalize window sizes.
    *   `<leader>+` / `<leader>-`: Increase/decrease height.
    *   `<leader>>` / `<leader><`: Increase/decrease width.
2.  **Tabs:**
    *   `<leader>tn`: Open a new tab.
    *   `<leader>tc`: Close current tab.
    *   `<leader>to`: Close all other tabs.
    *   `<leader>tl` or `gt`: Go to next tab.
    *   `<leader>th` or `gT`: Go to previous tab.
    *   `<leader>t<Space>`: List tabs.

## 5. Detailed Keybinding Reference

**Leader Key: `Space`**
**Local Leader Key: `\`**

(Note: Some LSP keybindings like `gd`, `K`, `gi`, `gr`, `<leader>ca`, `<leader>rn`, diagnostic navigation `[d`, `]d`, `<leader>de`, `<leader>dl` are defined in `lua-config.nix` within the LSP `on_attach` function, making them buffer-local and active when an LSP server is attached.)

**General & Navigation**
*   `<leader>w`: Save file
*   `<C-s>` (Insert Mode): Save file
*   `<leader>q`: Quit buffer
*   `<leader>Q`: Quit all (force)
*   `<leader>wq`: Save and quit
*   `<leader>bd`: Delete buffer
*   `<leader>bD`: Delete buffer (force)
*   `<leader>bn` or `<S-L>`: Next buffer
*   `<leader>bp` or `<S-H>`: Previous buffer
*   `<leader>bl`: List open buffers
*   `<C-h/j/k/l>`: Navigate window splits

**Window Management**
*   `<leader>sv`: Vertical split
*   `<leader>sH`: Horizontal split
*   `<leader>sc`: Close current window
*   `<leader>so`: Close other windows
*   `<leader>=`: Equalize window sizes
*   `<leader>+` / `<leader>-`: Adjust height
*   `<leader>>` / `<leader><`: Adjust width

**Tab Management**
*   `<leader>tn`: New tab
*   `<leader>tc`: Close tab
*   `<leader>to`: Close other tabs
*   `<leader>tl` or `gt`: Next tab
*   `<leader>th` or `gT`: Previous tab
*   `<leader>t<Space>`: List tabs

**Editing Enhancements**
*   `J` (Visual Mode): Move selected lines down
*   `K` (Visual Mode): Move selected lines up
*   `<` / `>` (Visual Mode): Indent/Un-indent
*   `<leader><space>`: Clear search highlight
*   `<leader>x`: Make current file executable
*   `<leader>so`: Source current file (vimscript/lua)

**Terminal**
*   `<leader>ft`: Open terminal (horizontal split)
*   `<leader>fT`: Open terminal (vertical split)
*   `<Esc>` (Terminal Mode): Exit to Normal mode
*   `<C-w>h/j/k/l` (Terminal Mode): Navigate out of terminal to splits

**Plugin: NvimTree (File Explorer)**
*   `<leader>e`: Toggle NvimTree
*   `<leader>fe`: Find current file in NvimTree

**Plugin: Telescope (Fuzzy Finder)**
*   `<leader>ff`: Find files
*   `<leader>fg`: Live grep in project
*   `<leader>fG`: Grep for string under cursor
*   `<leader>fb`: Find open buffers
*   `<leader>fh`: Find help tags
*   `<leader>fo`: Old files (recently opened)
*   `<leader>fz`: Fuzzy find in current buffer
*   **LSP (via Telescope):**
    *   `<leader>flr`: LSP References
    *   `<leader>fld`: LSP Definitions
    *   `<leader>fli`: LSP Implementations
    *   `<leader>fls`: LSP Document Symbols
    *   `<leader>flS`: LSP Workspace Symbols
*   **Other Telescope Pickers:**
    *   `<leader>fk`: Keymaps
    *   `<leader>fco`: Commands
    *   `<leader>fC`: Colorschemes
    *   `<leader>fm`: Marks
    *   `<leader>fR`: Registers
*   **Git (via Telescope):**
    *   `<leader>fgb`: Git branches
    *   `<leader>fgc`: Git commits (repository)
    *   `<leader>fgB`: Git buffer commits (current file)
    *   `<leader>fgs`: Git status

**Plugin: Fugitive (Git)**
*   `<leader>gs`: Git status window
*   `<leader>gc`: Git commit
*   `<leader>gp`: Git push
*   `<leader>gP`: Git pull
*   `<leader>gb`: Git blame
*   `<leader>gd`: Git diff current file (Gvdiffsplit)
*   `<leader>gh`: Git diffget from HEAD (in diff view)
*   `<leader>gu`: Git diffget from original (in diff view)
*   `<leader>gA`: Git add current file
*   `<leader>ga`: Git add all in repo
*   `<leader>gr`: Git restore current file
*   `<leader>gR`: Git restore all in repo

**Plugin: Comment.nvim**
*   `gcc`: Toggle line comment (Normal mode)
*   `gc` + motion: Toggle comment with motion
*   `<leader>/` (Visual Mode): Toggle comment for selection

**LSP (Language Server Protocol)**
*   `<leader>lf`: Format current buffer with LSP
*   (See `lua-config.nix` `on_attach` function for `gd`, `gi`, `K`, `<leader>ca`, `<leader>rn`, diagnostics, etc.)

**Quickfix & Location List**
*   `<leader>co` / `<leader>cc`: Open/Close quickfix list
*   `<leader>cn` / `<leader>cp`: Next/Previous in quickfix
*   `<leader>cf` / `<leader>cl`: First/Last in quickfix
*   `<leader>lo` / `<leader>lc`: Open/Close location list
*   `<leader>ln` / `<leader>lp`: Next/Previous in location list
*   `<leader>lL` / `<leader>ll`: First/Last in location list

**Spelling**
*   `<leader>sp`: Toggle spell check
*   `<leader>s?`: Next spelling error (same as `]s`)
*   `<leader>s!`: Previous spelling error (same as `[s`)
*   `<leader>sa`: Suggest corrections (same as `z=`)

## 6. Plugin Overview & Configuration

This setup uses several plugins, configured via Nix in `modules/common/neovim/plugins.nix` and `modules/common/neovim/lua-config.nix`.

*   **`vim-airline` & `vim-airline-themes`**
    *   Description: A stylish and informative status line.
    *   Docs: [vim-airline](https://github.com/vim-airline/vim-airline)
*   **`nvim-web-devicons`**
    *   Description: Adds file type icons to NvimTree, Telescope, Airline, etc.
    *   Docs: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
*   **`onsails/lspkind-nvim`**
    *   Description: Adds icons to `nvim-cmp` completion items based on LSP kind (function, variable, etc.).
    *   Docs: [lspkind-nvim](https://github.com/onsails/lspkind-nvim)
*   **`vim-fugitive`**
    *   Description: A comprehensive Git wrapper for Neovim. `:Git` is your friend.
    *   Docs: [vim-fugitive](https://github.com/tpope/vim-fugitive)
*   **`vim-gitgutter`**
    *   Description: Shows Git diff markers (added, modified, removed lines) in the sign column.
    *   Docs: [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
*   **`telescope-nvim` & `telescope-fzf-native-nvim`**
    *   Description: A highly extendable fuzzy finder. `fzf-native` provides a performance boost.
    *   Docs: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
*   **`nvim-tree-lua`**
    *   Description: A file explorer tree.
    *   Docs: [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
*   **`numToStr/Comment.nvim`**
    *   Description: Smart commenting plugin.
    *   Docs: [Comment.nvim](https://github.com/numToStr/Comment.nvim)
*   **`windwp/nvim-autopairs`**
    *   Description: Automatically closes pairs of brackets, quotes, etc.
    *   Docs: [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
*   **`nvim-treesitter`**
    *   Description: Provides advanced syntax highlighting, indentation, and other language parsing features. Parsers are automatically installed.
    *   Docs: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
*   **`nvim-lspconfig`**
    *   Description: Helper configurations for Neovim's built-in LSP client. Language servers are defined in `modules/common/neovim/default.nix` under `home.packages`.
    *   Docs: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
*   **`nvim-cmp`**
    *   Description: Autocompletion plugin. Sources include LSP, Luasnip, buffer words, and paths.
    *   Docs: [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
*   **`luasnip` & `rafamadriz/friendly-snippets`**
    *   Description: `luasnip` is a snippet engine. `friendly-snippets` provides a large collection of commonly used snippets.
    *   Docs: [luasnip](https://github.com/L3MON4D3/LuaSnip), [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
*   **`gruvbox`**
    *   Description: The current colorscheme.
    *   Docs: [gruvbox (community)](https://github.com/morhetz/gruvbox) or the specific vim plugin version.

## 7. Custom Macros

Macros allow you to record and replay sequences of keystrokes.

*   **Recording a Macro:**
    1.  In Normal mode, type `q` followed by a letter (e.g., `qa`) to start recording into register `a`.
    2.  Perform the sequence of actions you want to record.
    3.  Press `q` again to stop recording.
*   **Playing a Macro:**
    *   Type `@a` to play the macro stored in register `a`.
    *   Type `@@` to replay the last executed macro.
*   **Defining Macros in Configuration:**
    *   You can persist useful macros in `modules/common/neovim/lua-config.nix` in the "Custom Macros" section.
    *   Example (from `lua-config.nix`):
        ```lua
        -- Placeholder for user-defined macros:
        -- vim.fn.setreg('q', 'iHello NixVim User!\<Esc>', 'c') -- Example: content for register q
        -- vim.api.nvim_set_keymap('n', '<leader>mq', '@q', { noremap = true, silent = true, desc = "Run macro q" })
        ```
    *   To use this example: uncomment those lines in `lua-config.nix`, rebuild Home Manager. Then `<leader>mq` will run the "Hello NixVim User!" macro.
    *   Follow the instructions in `lua-config.nix` to add your own recorded macros.

## 8. Troubleshooting & Tips

*   **LSP Not Working?**
    *   Ensure the relevant language server is installed in `modules/common/neovim/default.nix` (`home.packages`).
    *   Check `:LspInfo` to see if the LSP is attached to your buffer.
    *   Check `:messages` for any error messages.
*   **Telescope Performance:** `telescope-fzf-native-nvim` is included for better performance. If it seems slow, ensure `cmake` and `gcc` (or `clang`) were correctly installed by Nix.
*   **View Error Messages:** Type `:messages` to see a history of Neovim messages and errors.
*   **Check Plugin Health:** Some plugins might have health checks (e.g. `:checkhealth telescope`).
*   **Updating Plugins/Neovim:** Edit your Nix configuration files and run `home-manager switch`. If you want to update to newer plugin versions than what your current Nix channel provides, you might need to update your Nix channels.

## 9. Further Customization

Your Neovim setup is defined in Nix files. If this `NEOVIM_TUTORIAL.md` file is part of a Git repository containing your Nix configuration, the primary Neovim files are likely located in a subdirectory such as `modules/common/neovim/`. If you are managing your dotfiles differently, this path might vary (e.g. `~/.config/home-manager/modules/common/neovim/`).

The key files are typically:
*   `default.nix`: Main entry point for Neovim config, includes supporting packages.
*   `options.nix`: Basic Neovim `set` options.
*   `keymaps.nix`: Custom keybindings.
*   `plugins.nix`: List of plugins installed via Nix.
*   `lua-config.nix`: Lua configuration for plugins and advanced settings.

Feel free to explore these files and tailor them to your needs. The beauty of Nix is that if you make a mistake, you can always roll back to a previous generation of your Home Manager configuration!

Happy Vimming!
```
