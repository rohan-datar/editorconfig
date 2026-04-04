require("lze").register_handlers({
	spec_field = "for_cat",
	set_lazy = false,
	modify = function(plugin)
		if vim.g.nix_info_plugin_name then
			if type(plugin.for_cat) == "table" then
				plugin.enabled = nixInfo(plugin.for_cat.default, "info", "cats", plugin.for_cat.cat)
			elseif type(plugin.for_cat) == "string" then
				plugin.enabled = nixInfo(false, "info", "cats", plugin.for_cat)
			end
		end
		return plugin
	end,
})
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
	{
		"nvim-surround",
		for_cat = "core",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-surround").setup({})
		end,
	},
	{ import = "plugins.mini" },
	{ import = "plugins.completion" },
	{ import = "plugins.format" },
	{ import = "plugins.lint" },
	{ import = "plugins.files" },
	{ import = "plugins.notifications" },
	{ import = "plugins.folding" },
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
			{ "<c-w>h", "<cmd>TmuxNavigateLeft<cr>", mode = { "n" } },
			{ "<c-w>j", "<cmd>TmuxNavigateDown<cr>", mode = { "n" } },
			{ "<c-w>k", "<cmd>TmuxNavigateUp<cr>", mode = { "n" } },
			{ "<c-w>l", "<cmd>TmuxNavigateRight<cr>", mode = { "n" } },
			{ "<c-w>\\", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n" } },
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
		lazy = false,
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
	{ import = "plugins.debugger" },
	{
		"direnv.vim",
		for_cat = "extras",
		event = "DeferredUIEnter",
	},
	{
		"golden-ratio",
		for_cat = "extras",
		event = "DeferredUIEnter",
	},
	{
		"eyeliner.nvim",
		for_cat = "ui",
		event = "DeferredUIEnter",
		after = function()
			require("eyeliner").setup({
				highlight_on_key = true,
				dim = true,
			})
		end,
	},
})

if nixInfo(false, "info", "cats", "lsp") then
	require("lsp")
end
