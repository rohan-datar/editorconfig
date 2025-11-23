return {
	"nvim-lint",
	for_cat = "editing",
	event = { "BufReadPre", "BufNewFile" },
	after = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			swift = { "swiftlint" },
			go = { "golangcilint" },
			python = { "pylint" },
			yaml = { "yamllint" },
			sh = { "shellcheck" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
			group = lint_augroup,
			callback = function()
				require("lint").try_lint()

				require("lint").try_lint("codespell")
			end,
		})

		vim.keymap.set("n", "<leader>ml", function()
			require("lint").try_lint()
		end, { desc = "Lint file" })
	end,
}
