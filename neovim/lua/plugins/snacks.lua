return {
	"folke/snacks.nvim",
	priority = 1000,
	for_cat = "core",
	lazy = false,
	after = function()
		require("snacks").setup({
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			-- dashboard = {
			-- 	enabled = true,
			-- 	example = "files",
			-- },
			indent = {
				enabled = true,
				animate = { enabled = false },
			},
			scope = { enabled = true },
			quickfile = { enabled = true },
			picker = {
				sources = {
					files = { hidden = true },
					grep = { hidden = true },
					explorer = { hidden = true },
				},
				win = {
					input = {
						keys = {
							["<Tab>"] = { "list_down", mode = { "i", "n" } },
							["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
							["<c-j>"] = { "select_and_next", mode = { "i", "n" } },
							["<c-k>"] = { "select_and_prev", mode = { "i", "n" } },
						},
					},
				},
				ui_select = true,
			},
		})

		local picker = require("snacks.picker")
		vim.api.nvim_create_user_command("Help", picker.help, {
			desc = "Snacks.picker.help",
		})

		vim.api.nvim_create_user_command("ManK", picker.man, {
			desc = "Snacks.picker.man",
		})

		vim.api.nvim_create_user_command("Colors", picker.colorschemes, {
			desc = "Snacks.picker.colorschemes",
		})

		vim.api.nvim_create_user_command("Commands", picker.commands, {
			desc = "Snacks.picker.commands",
		})
	end,

	keys = {
		-- General keymaps
		{
			"<leader><leader>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Search",
			mode = { "n" },
		},
		{
			"<leader>f",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
			mode = { "n" },
		},
		{
			"<leader>b",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Find Buffers",
			mode = { "n" },
		},
		{
			"<leader>qf",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
			mode = { "n" },
		},
		{
			"<leader>h",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
			mode = { "n" },
		},
		{
			"<leader>mm",
			function()
				Snacks.picker.man()
			end,
			desc = "Man Pages",
			mode = { "n" },
		},
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
			mode = { "n" },
		},
		{
			"<leader>u",
			function()
				Snacks.picker.undo({
					layout = { preset = "sidebar", preview = true },
				})
			end,
			mode = { "n" },
		},

		-- Grep
		{
			"<leader>gr",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
			mode = { "n" },
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep Word",
			mode = { "n", "x" },
		},
		{
			"<leader>/",
			function()
				Snacks.picker.lines()
			end,
			desc = "Grep in buffer",
			mode = { "n" },
		},
	},
}
