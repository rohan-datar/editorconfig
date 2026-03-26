return {
	"compile.nvim",
	for_cat = "compile",
	event = "DeferredUIEnter",
	after = function()
		local C = require("compile")
		C.setup({})

		local last_cmd

		vim.api.nvim_create_user_command("Compile", function(params)
			local args = params.args
			if args ~= "" then
				last_cmd = args
				C.compile(args)
				return
			end

			if last_cmd and last_cmd ~= "" then
				C.compile(last_cmd)
			else
				vim.ui.input({ prompt = "Compile command:" }, function(input)
					if input and input ~= "" then
						last_cmd = input
						C.compile(input)
					else
						C.compile()
					end
				end)
			end
		end, { nargs = "*", complete = "file", desc = "Run compilation command" })

		vim.api.nvim_create_user_command("Recompile", function()
			if last_cmd and last_cmd ~= "" then
				C.compile(last_cmd)
			else
				C.compile()
			end
		end, { desc = "Re-run last :Compile command" })

		vim.keymap.set("n", "<localleader>cc", ":Compile ", { desc = "compiler prompt" })
		vim.keymap.set("n", "<localleader>rc", "<cmd>Recompile<cr>", { desc = "Run last compiler command" })
	end,
}
