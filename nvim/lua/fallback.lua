if vim.g.nix_info_plugin_name == nil then
	-- basic plugins
	vim.pack.add({
		"https://github.com/BirdeeHub/lze",
		"https://github.com/BirdeeHub/lzextras",
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/nvim-mini/mini.nvim",
		"https://github.com/folke/snacks.nvim",
		"https://github.com/Saghen/blink.cmp",
		{ "https://github.com/catppuccin/nvim", name = "catppuccin.nvim" },
		"https://github.com/mfussenegger/nvim-lint",
		"https://github.com/stevearc/conform.nvim",
		"https://github.com/j-hui/fidget.nvim",
		"https://github.com/asiryk/auto-hlsearch.nvim",
		"https://github.com/kylechui/nvim-surround",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/williamboman/mason.nvim",
		"https://github.com/williamboman/mason-lspconfig.nvim",
		"https://github.com/stevearc/oil.nvim",
		"https://github.com/tpope/vim-repeat",
		"https://github.com/tpope/vim-abolish",
		"https://github.com/tpope/vim-sleuth",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		"https://github.com/christoomey/vim-tmux-navigator",
		"https://github.com/folke/todo-comments.nvim",
		"https://github.com/kevinhwang91/nvim-ufo",
		"https://github.com/kevinhwang91/promise-async",
		"https://github.com/luukvbaal/statuscol.nvim",
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
		"https://github.com/stevearc/quicker.nvim",
		"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
		"https://github.com/zbirenbaum/copilot.lua",
		"https://github.com/fang2hou/blink-copilot",
		"https://github.com/lewis6991/gitsigns.nvim",
		"https://github.com/NeogitOrg/neogit",
		"https://github.com/folke/lazydev.nvim",
		"https://github.com/ray-x/go.nvim",
		"https://github.com/mrcjkb/rustaceanvim",
		"https://github.com/obsidian-nvim/obsidian.nvim",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/mfussenegger/nvim-dap",
		"https://github.com/MironPascalCaseFan/debugmaster.nvim",
		"https://github.com/leoluz/nvim-dap-go",
		"https://github.com/MysticalDevil/inlay-hints.nvim",
		"https://github.com/pohlrabi404/compile.nvim",
		"https://github.com/direnv/direnv.vim",
		"https://github.com/roman/golden-ratio",
		"https://github.com/rachartier/tiny-code-action.nvim",
	})

	-- plugins with extra build steps
	vim.api.nvim_create_autocmd("User", {
		pattern = "PackChanged",
		callback = function(ev)
			if ev.data.spec.name == "nvim-treesitter" and (ev.data.kind == "install" or ev.data.kind == "update") then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
			end
		end,
	})
	vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

	vim.api.nvim_create_autocmd("User", {
		pattern = "PackChanged",
		callback = function(ev)
			if ev.data.spec.name == "LuaSnip" and ev.data.kind == "install" then
				if vim.fn.executable("make") == 1 and vim.fn.has("win32") == 0 then
					vim.fn.system({ "make", "-C", ev.data.path, "install_jsregexp" })
				end
			end
		end,
	})
	vim.pack.add({ "https://github.com/L3MON4D3/LuaSnip" })
end
