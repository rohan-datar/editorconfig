return {
	"quicker.nvim",
	for_cat = "ui",
	event = "FileType qf",
	after = function()
		require("quicker").setup({
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		})
	end,
	keys = {
		{
			"<leader>q",
			function()
				require("quicker").toggle()
			end,
			mode = { "n" },
			desc = "Toggle quickfix list",
		},
		{
			"<leader>e",
			function()
				vim.diagnostic.setqflist({ open = true, title = "Diagnostics" })
			end,
			mode = { "n" },
			desc = "Show all diagnostic messages",
		},
		{
			"<leader>eE",
			function()
				vim.diagnostic.setqflist({
					open = true,
					title = "Diagnostics (Errors)",
					severity = { min = sev.ERROR, max = sev.ERROR },
				})
			end,
			mode = { "n" },
			desc = "Show errors",
		},
	},
}
