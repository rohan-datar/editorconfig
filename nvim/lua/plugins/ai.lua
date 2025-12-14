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
	{
		"CopilotChat.nvim",
		for_cat = "ai",
		event = "DeferredUIEnter",
		keys = {
			{
				"<leader>ch",
				function()
					vim.cmd.CopilotChatToggle()
				end,
				mode = { "n" },
				desc = "Open chat buffer",
			},
		},
		after = function()
			require("CopilotChat").setup()
		end,
	},
}
