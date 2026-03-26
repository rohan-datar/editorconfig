return {
	"blink.cmp",
	lazy = false,
	for_cat = "core",
	on_require = "blink.cmp",
	after = function()
		local snips = {}
		if nixInfo(false, "info", "cats", "snippets") then
			snips = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				active = function(filter)
					if filter and filter.direction then
						return require("luasnip").jumpable(filter.direction)
					end
					return require("luasnip").in_snippet()
				end,
				jump = function(direction)
					require("luasnip").jump(direction)
				end,
			}
		end

		local providers = {}
		if nixInfo(false, "info", "cats", "ai") then
			providers.copilot = {
				name = "copilot",
				module = "blink-copilot",
				score_offset = 100,
				async = true,
			}
		end

		require("blink.cmp").setup({
			-- 'default' for mappings similar to built-in completion
			-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
			-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
			-- see the "default configuration" section below for full documentation on how to define
			-- your own keymap.
			keymap = {
				preset = "none",
				["<Tab>"] = {
					function(cmp)
						if cmp.is_visible then
							return cmp.select_next()
						end
						if cmp.snippet_active() then
							return cmp.snippet_forward()
						end
						return false
					end,
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_visible then
							return cmp.select_prev()
						end
						if cmp.snippet_active() then
							return cmp.snippet_backward()
						end
						return false
					end,
					"fallback",
				},
				["<CR>"] = { "accept", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
				["<C-e>"] = { "hide", "cancel", "fallback" },

				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},

			snippets = snips,
			-- default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, via `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				-- optionally disable cmdline completions
				-- cmdline = {},
				providers = providers,
			},

			-- experimental signature help support
			signature = { enabled = true },
			completion = {
				trigger = { show_in_snippet = false },
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},

				menu = {
					draw = {
						columns = { { "label", "label_description", gap = 3 }, { "kind_icon", "kind" } },
					},
				},
			},
		})
	end,
}
