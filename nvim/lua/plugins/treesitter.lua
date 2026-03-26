return {
	{
		"nvim-treesitter-context",
		for_cat = "editing",
		dep_of = "nvim-treesitter",
	},
	{
		"nvim-treesitter",
		for_cat = "editing",
		branch = "main",
		lazy = false,
		after = function()
			---@param buf integer
			---@param language string
			---@return boolean
			local function treesitter_try_attach(buf, language)
				-- check if parser exists and load it
				if not vim.treesitter.language.add(language) then
					return false
				end
				-- enables syntax highlighting and other treesitter features
				vim.treesitter.start(buf, language)

				-- enables treesitter based folds
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

				-- enables treesitter based indentation (disabled for ruby)
				local filetype = vim.bo[buf].filetype
				if filetype ~= "ruby" then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end

				return true
			end

			local available_parsers = require("nvim-treesitter").get_available()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match
					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					-- Prefer runtime/Nix-provided parsers before attempting install.
					if treesitter_try_attach(buf, language) then
						return
					end

					if vim.tbl_contains(available_parsers, language) then
						-- if a parser is available in `nvim-treesitter` enable it after ensuring it is installed
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					else
						-- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
						treesitter_try_attach(buf, language)
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter-textobjects",
		for_cat = "editing",
		lazy = false,
		after = function()
			-- Setup textobjects
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					include_surrounding_whitespace = true,
				},
			})

			-- Textobject keymaps
			vim.keymap.set({ "x", "o" }, "aa", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ia", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "af", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "as", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
			end)

			-- Swap keymaps
			vim.keymap.set("n", "<leader>a", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { desc = "Swap with next parameter" })
			vim.keymap.set("n", "<leader>A", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { desc = "Swap with previous parameter" })
		end,
	},
}
