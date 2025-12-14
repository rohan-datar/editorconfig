require("nixCatsUtils.catPacker").setup({
	-- non-lazy loaded
	{ "BirdeeHub/lze" },
	{ "BirdeeHub/lzextras" },
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-mini/mini.nvim" },
	{ "folke/snacks.nvim" },
	{ "Saghen/blink.cmp" },
	{ "catppuccin/nvim" },
	{ "mfussenegger/nvim-lint" },
	{ "stevearc/conform.nvim" },
	{ "j-hui/fidget.nvim" },
	{ "asiryk/auto-hlsearch.nvim" },
	{ "kylechui/nvim-surround" },

	-- lazy loaded
	{ "neovim/nvim-lspconfig", opt = true },
	{ "williamboman/mason.nvim", opt = true },
	{ "williamboman/mason-lspconfig.nvim", opt = true },
	{ "stevearc/oil.nvim", opt = true },
	{ "tpope/vim-repeat", opt = true },
	{ "tpope/vim-abolish", opt = true },
	{ "tpope/vim-sleuth", opt = true },
	{ "nvim-treesitter/nvim-treesitter-textobjects", opt = true },
	{ "RRethy/nvim-treesitter-textsubjects", opt = true },
	{ "nvim-treesitter/nvim-treesitter-textobjects", opt = true },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opt = true },
	{ "tope/vim-abolish", opt = true },
	{ "christoomey/vim-tmux-navigator", opt = true },
	{ "folke/todo-comments.nvim", opt = true },
	{ "kevinhwang91/nvim-ufo", opt = true },
	{ "kevinhwang91/promise-async", opt = true },
	{ "luukvbaal/statuscol.nvim", opt = true },
	{ "MeanderingProgrammer/render-markdown.nvim", opt = true },
	{ "sevearc/quicker.nvim", opt = true },
	{ "achartier/tiny-inline-diagnostic.nvim", opt = true },
	{ "zbirenbaum/copilot.lua", opt = true },
	{ "fang2hou/blink-copilot", opt = true },
	{ "CopilotC-Nvim/CopilotChat.nvim", opt = true },
	{ "lewis6991/gitsigns.nvim", opt = true },
	{ "NeogitOrg/neogit", opt = true },
	{ "folke/lazydev.nvim", opt = true },
	{ "ray-x/go.nvim", opt = true },
	{ "mrcjkb/rustaceanvim", opt = true },
	{ "obsidian-nvim/obsidian.nvim", opt = true },
	{ "rafamadriz/friendly-snippets", opt = true },
	{ "mfussenegger/nvim-dap", opt = true },
	{ "igorlfs/nvim-dap-view", opt = true },
	{ "leoluz/nvim-dap-go", opt = true },
	{
		"L3MON4D3/LuaSnip",
		opt = true,
		build = (function()
			-- Build Step is needed for regex support in snippets.
			-- This step is not supported in many windows environments.
			-- Remove the below condition to re-enable on windows.
			if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				return
			end
			return "make install_jsregexp"
		end)(),
	},
	{ "MysticalDevil/inlay-hints.nvim", opt = true },
	{ "pohlrabi404/compile.nvim", opt = true },
})
