require("lze").register_handlers(require("nixCatsUtils.lzUtils").for_cat)

require("lze").load({
	{
		"catppuccin",
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
	{ import = "plugins.mini" },
	{ import = "plugins.completion" },
	{ import = "plugins.format" },
	{ import = "plugins.lint" },
	{ import = "plugins.files" },
	{ import = "plugins.notifications" },
})
