require("lze").register_handlers(require("nixCatsUtils.lzUtils").for_cat)
require("lze").register_handlers(require("lzextras").lsp)

require("lze").load({
	{
		"catppuccin-nvim",
		priority = 1000,
		lazy = false,
		colorscheme = "catppuccin",
		for_cat = "core",
		after = function()
			require("catppuccin").setup({
				flavor = "mocha",
				transparent_background = true,
				show_end_of_buffer = true,
				float = {
					transparent = true,
				},
			})
			vim.cmd("colorscheme catppuccin")
		end,
	},
	{ import = "plugins.snacks" },
	{ "vim-sleuth", for_cat = "core" },
	{ "vim-repeat", for_cat = "core" },
	{ "vim-abolish", for_cat = "core" },
	{ import = "plugins.mini" },
	{ import = "plugins.completion" },
	{ import = "plugins.format" },
	{ import = "plugins.lint" },
	{ import = "plugins.files" },
	{ import = "plugins.notifications" },
	{
		"auto-hlsearch.nvim",
		for_cat = "core",
		after = function()
			require("auto-hlsearch").setup()
		end,
	},
	{
		"vim-tmux-navigator",
		for_cat = "core",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = { "n" } },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = { "n" } },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = { "n" } },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = { "n" } },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", mode = { "n" } },
		},
	},
	{ import = "plugins.treesitter" },
	{ "todo-comments.nvim", for_cat = "ui" },
	{ import = "plugins.snippets" },
	{ import = "plugins.ai" },
	{
		"render-markdown.nvim",
		for_cat = "ui",
		after = function()
			require("render-markdown").setup()
		end,
		keys = {
			{ "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", mode = { "n" } },
		},
	},
	{
		"tiny-inline-diagnostic.nvim",
		for_cat = "ui",
		event = "DeferredUIEnter",
		priority = 999,
		before = function()
			vim.diagnostic.config({ virtual_text = false })
		end,
		after = function()
			require("tiny-inline-diagnostic").setup({
				preset = "classic",
			})
		end,
	},
	{ import = "plugins.quickfix" },
	{ import = "plugins.git" },
	{ import = "plugins.compile" },
})
