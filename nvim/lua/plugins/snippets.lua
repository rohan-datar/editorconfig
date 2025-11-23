return {
	{
		"friendly-snippets",
		for_cat = "snippets",
		on_plugin = "luasnip",
		after = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"luasnip",
		for_cat = "snippets",
		on_plugin = "blink.cmp",
	},
}
