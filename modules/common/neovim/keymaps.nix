# modules/common/neovim/keymaps.nix
{ lib, pkgs, ... }:
{
  # This file defines custom keybindings for Neovim.
  # The leader key is set to <Space>.
  # For more details on mappings, see :help map in Neovim.

  extraConfig = ''
    " -----------------------------------------------------------------------------
    " Leader Key
    " -----------------------------------------------------------------------------
    let mapleader = " "
    let maplocalleader = "\" " Local leader for filetype-specific maps or less common global maps

    " -----------------------------------------------------------------------------
    " General & Navigation
    " -----------------------------------------------------------------------------
    " Faster saving/quitting
    nnoremap <leader>w :w<CR>
    vnoremap <leader>w <C-C>:w<CR> " Save visual selection (ensure editor behaves as expected)
    inoremap <C-s> <Esc>:w<CR>a " Save in insert mode

    nnoremap <leader>q :q<CR>
    nnoremap <leader>Q :qa!<CR> " Force quit all
    nnoremap <leader>wq :wq<CR>

    " Close buffer
    nnoremap <leader>bd :bdelete<CR>
    nnoremap <leader>bD :bdelete!<CR> " Force close buffer without saving

    " Buffer navigation
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <S-L> :bnext<CR>
    nnoremap <S-H> :bprevious<CR>
    nnoremap <leader>bl :ls<CR> " List open buffers

    " Window navigation (using Ctrl + hjkl)
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    " Window management
    nnoremap <leader>sv :vsplit<CR>
    nnoremap <leader>sH :split<CR> " Changed from <leader>sh to avoid LSP conflict
    nnoremap <leader>sc <C-w>c " Close current window
    nnoremap <leader>so <C-w>o " Close other windows (only current)

    " Resize windows
    nnoremap <leader>= <C-w>= " Equalize window sizes
    nnoremap <leader>+ :resize +2<CR>
    nnoremap <leader>- :resize -2<CR>
    nnoremap <leader>> :vertical resize +2<CR>
    nnoremap <leader>< :vertical resize -2<CR>

    " Tab navigation
    nnoremap <leader>tn :tabnew<CR>
    nnoremap <leader>tc :tabclose<CR>
    nnoremap <leader>to :tabonly<CR>
    nnoremap <leader>tl :tabnext<CR>
    nnoremap <leader>th :tabprevious<CR>
    nnoremap <leader>t<Space> :tabs<CR> " List tabs

    " -----------------------------------------------------------------------------
    " Editing Enhancements
    " -----------------------------------------------------------------------------
    " Move selected lines up/down in visual mode
    vnoremap J :m '>+1<CR>gv=gv
    vnoremap K :m '<-2<CR>gv=gv

    " Indent/un-indent in visual mode
    vnoremap < <gv
    vnoremap > >gv

    " Clear search highlight
    nnoremap <leader><space> :noh<CR>

    " Make current file executable
    nnoremap <leader>x <cmd>!chmod +x %<CR><CR>

    " Source current file (useful for Vimscript or Lua config)
    nnoremap <leader>so <cmd>so %<CR>

    " -----------------------------------------------------------------------------
    " Terminal Mappings
    " -----------------------------------------------------------------------------
    nnoremap <leader>ft <cmd>split term://zsh<CR><C-w>j:resize 15<CR>i " Open terminal in horizontal split
    nnoremap <leader>fT <cmd>vsplit term://zsh<CR>i " Open terminal in vertical split
    tnoremap <Esc> <C-\><C-n> " Exit terminal mode to normal mode
    tnoremap <C-v><Esc> <Esc> " Allow sending literal Esc in terminal mode
    tnoremap <C-w>h <C-\><C-N><C-w>h " Terminal window navigation (to left split)
    tnoremap <C-w>j <C-\><C-N><C-w>j " Terminal window navigation (to split below)
    tnoremap <C-w>k <C-\><C-N><C-w>k " Terminal window navigation (to split above)
    tnoremap <C-w>l <C-\><C-N><C-w>l " Terminal window navigation (to right split)

    " -----------------------------------------------------------------------------
    " Plugin: NvimTree (File Explorer)
    " -----------------------------------------------------------------------------
    nnoremap <leader>e :NvimTreeToggle<CR>
    nnoremap <leader>fe :NvimTreeFindFile<CR> " Find current file in NvimTree and focus

    " -----------------------------------------------------------------------------
    " Plugin: Telescope (Fuzzy Finder)
    " -----------------------------------------------------------------------------
    nnoremap <leader>ff <cmd>Telescope find_files<cr> " Find files
    nnoremap <leader>fg <cmd>Telescope live_grep<cr> " Live grep in project
    nnoremap <leader>fG <cmd>Telescope grep_string<cr> " Grep for string under cursor in project
    nnoremap <leader>fb <cmd>Telescope buffers<cr> " Find open buffers
    nnoremap <leader>fh <cmd>Telescope help_tags<cr> " Find help tags
    nnoremap <leader>fo <cmd>Telescope oldfiles<cr> " Recently opened files
    nnoremap <leader>fz <cmd>Telescope current_buffer_fuzzy_find<cr> " Fuzzy find in current buffer
    
    " LSP related telescope pickers
    nnoremap <leader>flr <cmd>Telescope lsp_references<cr> " Renamed from <leader>fr to group LSP specific telescope maps
    nnoremap <leader>fld <cmd>Telescope lsp_definitions<cr> " Renamed from <leader>fd
    nnoremap <leader>fli <cmd>Telescope lsp_implementations<cr> " Renamed from <leader>fi
    nnoremap <leader>fls <cmd>Telescope lsp_document_symbols<cr> " Renamed from <leader>fs
    nnoremap <leader>flS <cmd>Telescope lsp_workspace_symbols<cr> " Renamed from <leader>fS

    " Additional useful Telescope pickers
    nnoremap <leader>fk <cmd>Telescope keymaps<cr> " Show keymaps
    nnoremap <leader>fco <cmd>Telescope commands<cr> " Show commands (renamed from fc to avoid conflict with fugitive commit)
    nnoremap <leader>fC <cmd>Telescope colorscheme<cr> " Show colorschemes
    nnoremap <leader>fm <cmd>Telescope marks<cr> " Show marks
    nnoremap <leader>fR <cmd>Telescope registers<cr> " Show registers

    " Git related Telescope pickers
    nnoremap <leader>fgb <cmd>Telescope git_branches<cr> " Git branches
    nnoremap <leader>fgc <cmd>Telescope git_commits<cr> " Git commits for repository
    nnoremap <leader>fgB <cmd>Telescope git_bcommits<cr> " Git buffer commits (current file)
    nnoremap <leader>fgs <cmd>Telescope git_status<cr> " Git status

    " -----------------------------------------------------------------------------
    " Plugin: Fugitive (Git)
    " -----------------------------------------------------------------------------
    nnoremap <leader>gs <cmd>Git<CR> 
    nnoremap <leader>gc <cmd>Git commit<CR>
    nnoremap <leader>gp <cmd>Git push<CR>
    nnoremap <leader>gP <cmd>Git pull<CR> " Changed from gl
    nnoremap <leader>gb <cmd>Git blame<CR>
    nnoremap <leader>gd <cmd>Gvdiffsplit<CR> 
    nnoremap <leader>gh <cmd>diffget //2<CR> 
    nnoremap <leader>gu <cmd>diffget //3<CR> 
    nnoremap <leader>gA <cmd>Git add %<CR> 
    nnoremap <leader>ga <cmd>Git add .<CR> 
    nnoremap <leader>gr <cmd>Git restore %<CR> 
    nnoremap <leader>gR <cmd>Git restore .<CR> 

    " -----------------------------------------------------------------------------
    " Plugin: Comment.nvim
    " -----------------------------------------------------------------------------
    vnoremap <leader>/ <cmd>CommentToggle<CR>gv " Toggle comment for visual selection

    " -----------------------------------------------------------------------------
    " LSP (Language Server Protocol) related mappings
    " -----------------------------------------------------------------------------
    " Most LSP mappings are buffer-local (defined in lua-config.nix on_attach)
    nnoremap <leader>lf <cmd>lua vim.lsp.buf.format({ async = true })<CR> " Format current buffer
    
    " Reminders for LSP diagnostics mappings (defined in lua-config.nix):
    " <leader>de: Show diagnostic float
    " [d: Previous diagnostic
    " ]d: Next diagnostic
    " <leader>dl: Show diagnostics in location list

    " -----------------------------------------------------------------------------
    " Quickfix & Location List Navigation
    " -----------------------------------------------------------------------------
    nnoremap <leader>co :copen<CR> 
    nnoremap <leader>cc :cclose<CR> 
    nnoremap <leader>cn :cnext<CR>
    nnoremap <leader>cp :cprevious<CR>
    nnoremap <leader>cf :cfirst<CR>
    nnoremap <leader>cl :clast<CR>

    nnoremap <leader>lo :lopen<CR> 
    nnoremap <leader>lc :lclose<CR> 
    nnoremap <leader>ln :lnext<CR>
    nnoremap <leader>lp :lprevious<CR>
    nnoremap <leader>lL :lfirst<CR> " Changed from <leader>lf to avoid LSP format conflict
    nnoremap <leader>ll :llast<CR>

    " -----------------------------------------------------------------------------
    " Spelling
    " -----------------------------------------------------------------------------
    nnoremap <leader>sp <cmd>set spell!<CR> " Toggle spell check
    nnoremap <leader>s? ]s " Next spelling error
    nnoremap <leader>s! [s " Previous spelling error
    nnoremap <leader>sa z= " Suggest corrections
  '';
}
