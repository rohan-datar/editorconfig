local catUtils = require("nixCatsUtils")

-- NOTE: This file uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- This is a slightly more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- nixCats gives us the paths, which is faster than searching the rtp!
local old_ft_fallback = require("lze").h.lsp.get_ft_fallback()
require("lze").h.lsp.set_ft_fallback(function(name)
	local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" })
		or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
	if lspcfg then
		local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
		if not ok then
			ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
		end
		return (ok and cfg or {}).filetypes or {}
	else
		return old_ft_fallback(name)
	end
end)

require("lze").load({
	{
		"nvim-lspconfig",
		for_cat = "lsp",
		on_require = { "lspconfig" },
		-- NOTE: define a function for lsp,
		-- and it will run for all specs with type(plugin.lsp) == table
		-- when their filetype trigger loads them
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function(_)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities =
				vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities(capabilities))
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			vim.lsp.config("*", {
				capabilities = capabilities,
			})
			require("lsp.on_attach")
		end,
	},
	{
		"mason.nvim",
		-- only run it when not on nix
		enabled = not catUtils.isNixCats,
		on_plugin = { "nvim-lspconfig" },
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("mason-lspconfig.nvim")
			require("mason").setup()
			-- auto install will make it install servers when lspconfig is called on them.
			require("mason-lspconfig").setup({ automatic_installation = true })
		end,
	},
	{
		"inlay-hints",
		for_cat = "lsp",
		event = "LspAttach",
		after = function()
			require("inlay-hints").setup()
		end,
		keys = {
			{
				"<leader>ih",
				"<cmd>InlayHintsToggle<cr>",
				desc = "toggle lsp inlay hints",
				mode = { "n" },
			},
		},
	},
	{
		"lazydev.nvim",
		for_cat = "lua",
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(_)
			require("lazydev").setup({
				library = {
					{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
				},
			})
		end,
	},
	{
		"rust-analyzer",
		lazy = false, -- needed because rustaceanvim needs it loaded early
		for_cat = "lsp",
		lsp = {
			inlayHints = {
				bindingModeHints = {
					enable = false,
				},
				chainingHints = {
					enable = true,
				},
				closingBraceHints = {
					enable = true,
					minLines = 25,
				},
				closureReturnTypeHints = {
					enable = "never",
				},
				lifetimeElisionHints = {
					enable = "never",
					useParameterNames = false,
				},
				maxLength = 25,
				parameterHints = {
					enable = true,
				},
				reborrowHints = {
					enable = "never",
				},
				renderColons = true,
				typeHints = {
					enable = true,
					hideClosureInitialization = false,
					hideNamedConstructor = false,
				},
			},
		},
	},
	{
		"go.nvim",
		for_cat = "extra",
		after = function()
			require("go").setup()
		end,
		event = "CmdLineEnter",
		ft = { "go", "gomod" },
	},
	{
		"lua_ls",
		for_cat = "lsp",
		lsp = {
			filetypes = { "lua" },
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					runtime = { version = "LuaJIT" },
					formatters = {
						ignoreComments = true,
					},
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { "nixCats", "vim" },
						disable = { "missing-fields" },
					},
					telemetry = { enabled = false },
					hint = { enable = true },
				},
			},
		},
	},
	{
		"clangd",
		for_cat = "compilers",
		lsp = {
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			settings = {
				clangd = {
					InlayHints = {
						Designators = true,
						Enabled = true,
						ParameterNames = true,
						DeducedTypes = true,
					},
					fallbackFlags = { "-std=c++20" },
				},
			},
			on_attach = require("lsp.on_attach"),
		},
	},
	{
		"gopls",
		for_cat = "lsp",
		lsp = {
			settings = {
				gopls = {
					hints = {
						rangeVariableTypes = true,
						parameterNames = true,
						constantValues = true,
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						functionTypeParameters = true,
					},
				},
			},
		},
	},
	{
		"nil_ls",
		for_cat = "lsp",
		lsp = {},
	},
	-- {
	-- 	"superhtml",
	-- 	for_cat = "lsp",
	-- 	lsp = {},
	-- },
	{
		"jdtls",
		for_cat = "lsp",
		lsp = {
			settings = {
				java = {
					inlayHints = {
						parameterNames = {
							enabled = "all",
							exclusions = { "this" },
						},
					},
				},
			},
		},
	},
	-- {
	-- 	"zls",
	-- 	for_cat = "lsp",
	-- 	lsp = {
	-- 		settings = {
	-- 			zls = {
	-- 				enable_inlay_hints = true,
	-- 				inlay_hints_show_builtin = true,
	-- 				inlay_hints_exclude_single_argument = true,
	-- 				inlay_hints_hide_redundant_param_names = false,
	-- 				inlay_hints_hide_redundant_param_names_last_token = false,
	-- 			},
	-- 		},
	-- 	},
	-- },
	{
		"sourcekit",
		for_cat = "lsp",
		lsp = {
			capabilities = {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			},
		},
	},
	{
		"markdown_oxide",
		for_cat = "lsp",
		lsp = {
			capabilities = {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			},
			on_attach = function(client, bufnr)
				local function check_codelens_support()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					for _, c in ipairs(clients) do
						if c.server_capabilities.codeLensProvider then
							return true
						end
					end
					return false
				end

				vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "CursorHold", "LspAttach", "BufEnter" }, {
					buffer = bufnr,
					callback = function()
						if check_codelens_support() then
							vim.lsp.codelens.refresh({ bufnr = 0 })
						end
					end,
				})
				-- trigger codelens refresh
				vim.api.nvim_exec_autocmds("User", { pattern = "LspAttached" })

				-- setup Markdown Oxide daily note commands
				if client.name == "markdown_oxide" then
					vim.api.nvim_create_user_command("Daily", function(args)
						local input = args.args

						client.exec_cmd({ command = "jump", arguments = { input } })
					end, { desc = "Open daily note", nargs = "*" })
				end
			end,
		},
	},
})
