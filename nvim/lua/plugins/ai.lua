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
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
	{
		"codecompanion.nvim",
		for_cat = "ai",
		keys = {
			{
				"<leader>ch",
				function()
					vim.cmd.CodeCompanionChat("Toggle")
				end,
				mode = { "n" },
				desc = "Open chat buffer",
			},
		},
		after = function()
			require("codecompanion").setup({
				strategies = {
					chat = {
						slash_commands = {
							["file"] = {
								opts = { provider = "snacks" },
								keymaps = {
									modes = {
										n = "<C-f>",
									},
								},
							},
							["buffer"] = {
								opts = { provider = "snacks" },
								keymaps = {
									modes = {
										n = { "<C-b>", "gb" },
										i = "<C-b>",
									},
								},
							},
						},
						opts = {
							---Decorate the user message before it's sent to the LLM
							prompt_decorator = function(message, adapter, context)
								return string.format([[<prompt>%s</prompt>]], message)
							end,
						},
					},
				},
				display = {
					window = {
						width = 0.3,
					},
					diff = {
						provider = "mini_diff",
					},
				},
			})
		end,
	},
}
