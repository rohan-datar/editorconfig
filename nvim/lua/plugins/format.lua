return {
	"conform.nvim",
	for_cat = "editing",
	after = function()
		require("conform").setup({
			notify_on_error = false,
			format_on_save = {
				timeout = 500,
				lsp_format = "fallback",
			},
			formatters = {
				["clang-format"] = {
					append_args = { '--style="{BasedOnStyle: Microsoft, IndentWidth: 2"' },
				},
			},
			formatters_by_ft = {
				c = { "clang-format" },
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use a sub-list to tell conform to run *until* a formatter
				-- is found.
				-- javascript = { { "prettierd", "prettier" } },
				go = { "gofmt", stop_after_first = true },
				-- templ = { "templ" },
				rust = { "rustfmt", lsp_format = "fallback" },
				yaml = { "yq" },
				json = { "jq" },
				swift = { "swiftformat" },
				nix = { "nixfmt" },
				html = { "superhtml" },
				["*"] = { "trim_newlines", "trim_whitespace" },
			},
		})
	end,
}
