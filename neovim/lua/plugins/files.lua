return {
	"oil.nvim",
	for_cat = "core",
	event = "DeferredUIEnter",
	before = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				local act = event.data.actions[1]
				if act.type == "move" then
					Snacks.rename.on_rename_file(act.src_url, act.dest_url)
				end
			end,
		})
	end,
	after = function()
		require("oil").setup({
			columns = {
				"permissions",
				"size",
				"icon",
			},
			view_options = {
				show_hidden = true,
			},
		})
	end,
	keys = {
		{
			"<leader>fe",
			vim.cmd.Oil,
			desc = "Open [F]ile [E]xplorer",
			mode = { "n" },
		},
	},
}
