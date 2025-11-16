return {
	"j-hui/fidget.nvim",
	for_cat = "extra",
	event = "DeferredUIEnter",
	after = function()
		local default_config = require("fidget.notification").default_config
		default_config.name = nil
		default_config.icon = nil
		require("fidget").setup({
			notification = {
				override_vim_notify = true,
				configs = {
					default = default_config,
				},
				window = {
					winblend = 0,
				},
			},
			progress = {
				display = {
					done_icon = "✓",
				},
			},
		})
	end,
}
