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
		"agentic.nvim",
		for_cat = "ai",
		after = function()
			require("agentic").setup({
				provider = "copilot-acp",
			})
		end,

		keys = {
			{
				"<C-\\>",
				function()
					require("agentic").toggle()
				end,
				mode = { "n", "v", "i" },
				desc = "Toggle Agentic Chat",
			},
			{
				"<C-'>",
				function()
					require("agentic").add_selection_or_file_to_context()
				end,
				mode = { "n", "v" },
				desc = "Add file or selection to Agentic to Context",
			},
			{
				"<C-,>",
				function()
					require("agentic").new_session()
				end,
				mode = { "n", "v", "i" },
				desc = "New Agentic Session",
			},
			{
				"<A-i>r", -- ai Restore
				function()
					require("agentic").restore_session()
				end,
				desc = "Agentic Restore session",
				silent = true,
				mode = { "n", "v", "i" },
			},
			{
				"<leader>ad", -- ai Diagnostics
				function()
					require("agentic").add_current_line_diagnostics()
				end,
				desc = "Add current line diagnostic to Agentic",
				mode = { "n" },
			},
			{
				"<leader>aD", -- ai all Diagnostics
				function()
					require("agentic").add_buffer_diagnostics()
				end,
				desc = "Add all buffer diagnostics to Agentic",
				mode = { "n" },
			},
		},
	},
}
