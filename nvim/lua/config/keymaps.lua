-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Easily enter a newline in normal mode
vim.keymap.set("n", "<Enter>", "o<Esc>")

-- Move selected text around in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--Keep cursor centered when scrolling
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- allows for pasted stuff to remain in the default register
vim.keymap.set(
	"x",
	"<leader>p",
	[["_dP]],
	{ noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)

-- also allow for deleting without copying
vim.keymap.set(
	{ "n", "v" },
	"<leader>d",
	[["_d]],
	{ noremap = true, silent = true, desc = "delete selection without erasing unnamed register" }
)

-- Quick replace word under my cursor everywhere in the document
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- terminal mode keymaps
vim.keymap.set("t", "<C-w><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-w>:", "<C-\\><C-n>:", { desc = "Enter command mode" })
vim.keymap.set("t", "<C-q>:", vim.cmd.quit, { desc = "Quit terminal mode" })
vim.keymap.set("t", "<C-w>_", function()
	vim.cmd.wincmd("_")
end)
vim.keymap.set("t", "<C-w>=", function()
	vim.cmd.wincmd("=")
end)
