return function(_, bufnr)
	-- we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.

	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("gd", function()
		Snacks.picker.lsp_definitions()
	end, "Go To Definition")

	nmap("gr", function()
		Snacks.picker.lsp_references()
	end, "Find All References")

	nmap("gi", function()
		Snacks.picker.lsp_implementations()
	end, "Go To Implementation")

	nmap("gD", function()
		Snacks.picker.lsp_type_definitions()
	end, "Go To Type Definition")

	nmap("<leader>ss", function()
		Snacks.picker.lsp_symbols()
	end, "LSP Symbols")

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

	-- Execute a code action, usually your cursor needs to be on top of an error
	-- or a suggestion from your LSP for this to activate.
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("<leader>cl", vim.lsp.codelens.run, "[C]ode[L]ens")

	nmap("<leader>k", function()
		vim.lsp.buf.code_action({
			filter = function(c)
				return c.kind == "source.doc"
			end,
			apply = true,
		})
	end, "open source documentation")

	-- Opens a popup that displays documentation about the word under your cursor
	--  See `:help K` for why this keymap.
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
end
