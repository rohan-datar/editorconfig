return {
	"stevearc/oil.nvim",
	for_cat = "core",
	event = "DeferredUIEnter",
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
}
