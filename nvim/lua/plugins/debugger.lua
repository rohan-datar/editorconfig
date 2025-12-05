return {
	{
		"nvim-dap-go",
		for_cat = "debugger",
		dep_of = "nvim-dap",
		after = function()
			require("dap-go").setup()
		end,
	},
	{
		"nvim-dap-view",
		for_cat = "debugger",
		dep_of = "nvim-dap",
		after = function()
			require("dap-view").setup()
		end,
	},
	{
		"nvim-dap",
		for_cat = "debugger",
		after = function()
			local dap = require("dap")
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			dap.configurations.c = {
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					args = {}, -- provide arguments if needed
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Select and attach to process",
					type = "gdb",
					request = "attach",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					pid = function()
						local name = vim.fn.input("Executable name (filter): ")
						return require("dap.utils").pick_process({ filter = name })
					end,
					cwd = "${workspaceFolder}",
				},
			}
		end,
		keys = {
			{ "<leader>dt", "<cmd>DapViewToggle<cr>", mode = { "n" } },
			{ "<leader>dc", "<cmd>DapContinue<cr>", mode = { "n" } },
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", mode = { "n" } },
			{ "<leader>dw", "<cmd>DapViewWatch<cr>", mode = { "n" } },
			{ "<leader>dp", "<cmd>DapPause<cr>", mode = { "n" } },
			{ "<leader>ds", "<cmd>DapStop<cr>", mode = { "n" } },
			{ "<leader>de", "<cmd>DapEvaluate<cr>", mode = { "n" } },
			{ "<leader>di", "<cmd>DapStepInto<cr>", mode = { "n" } },
			{ "<leader>do", "<cmd>DapStepOver<cr>", mode = { "n" } },
			{ "<leader>du", "<cmd>DapStepOut<cr>", mode = { "n" } },
			{ "<leader>dbk", "<cmd>DapStepBack<cr>", mode = { "n" } },
			{ "<leader>dr", "<cmd>DapRestart<cr>", mode = { "n" } },
			{ "<leader>drc", "<cmd>DapRunToCursor<cr>", mode = { "n" } },
		},
	},
}
