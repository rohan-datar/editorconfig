return {
	"mini.nvim",
	lazy = false,
	for_cat = "core",
	after = function()
		require("mini.icons").setup()

		-- statusline setup
		require("mini.statusline").setup({
			use_icons = true,
			content = {
				active = function()
					local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
					local git = MiniStatusline.section_git({ trunc_width = 75 })
					local diff = MiniStatusline.section_diff({ trunc_width = 75 })
					local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
					local filename = MiniStatusline.section_filename({ trunc_width = 75 })
					local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 75 })
					local location = MiniStatusline.section_location({ trunc_width = 75 })

					return MiniStatusline.combine_groups({
						{ hl = mode_hl, strings = { mode } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff } },
						{ hl = "MiniStatuslineDevinfo", strings = { diagnostics } },
						"%<",
						{ hl = "MiniStatuslineFileName", strings = { filename } },
						"%=",
						{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
						{ hl = mode_hl, strings = { location } },
					})
				end,
			},
		})
		vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { bg = "NONE" })

		require("mini.diff").setup({
			source = require("mini.diff").gen_source.none(),
		})

		require("mini.comment").setup()
		require("mini.align").setup()
		require("mini.bracketed").setup()
		require("mini.operators").setup()
		require("mini.ai").setup()
		require("mini.splitjoin").setup()
		require("mini.git").setup()
	end,
}
