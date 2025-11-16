-- [[ Setting options ]]

-- rounded borders on floating windows
vim.opt.winborder = "rounded"

-- cursor
vim.opt.guicursor = ""

-- indents
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.smartindent = true

-- mark 80 characters on a line
vim.opt.colorcolumn = "80"

--line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- windowing and splits
vim.opt.hidden = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = "a"

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"

-- Decrease update time
vim.opt.updatetime = 250

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 20

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- enable colors
vim.opt.termguicolors = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.opt.incsearch = true

-- For undo tree plugin to have access to undos
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- For Obsidian plugin, remove if it causes issues
vim.opt.conceallevel = 1
