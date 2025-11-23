return {
	{
		"neogit",
		for_cat = "git",
		cmd = "Neogit",
		after = function()
			require("neogit").setup()
		end,
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI", mode = { "n" } },
		},
	},
	{
		"gitsigns.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				current_line_blame = true,
			})
		end,
	},
}
