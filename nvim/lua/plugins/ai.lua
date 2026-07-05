return {
	{
		"blink-copilot",
		for_cat = "ai",
		dep_of = "blink.cmp",
	},
	{
		"copilot.lua",
		for_cat = "ai",
		cmd = "Copilot",
		event = "DeferredUIEnter",
		after = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					markdown = true,
					help = true,
				},
			})
		end,
	},
}
