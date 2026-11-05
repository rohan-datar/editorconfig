local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("BufReadCmd", {
		group = vim.api.nvim_create_augroup("lspkl_virtual_documents", { clear = true }),
		pattern = "lspkl://*",
		callback = function(event)
			local buf = event.buf
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].swapfile = false
			vim.bo[buf].modifiable = false
			vim.bo[buf].readonly = true

			-- Prefer the originating buffer's server in multi-workspace sessions.
			local client = vim.lsp.get_clients({ name = "lspkl", bufnr = vim.fn.bufnr("#") })[1]
				or vim.lsp.get_clients({ name = "lspkl" })[1]
			if not client then
				vim.notify("Cannot load Pkl source: lspkl is not running", vim.log.levels.ERROR)
				return
			end

			client:request("pkl/fileContents", { uri = event.match }, function(err, contents)
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				if err or type(contents) ~= "string" then
					vim.notify(
						"Cannot load Pkl source: " .. (err and err.message or "empty response"),
						vim.log.levels.ERROR
					)
					return
				end
				vim.bo[buf].readonly = false
				vim.bo[buf].modifiable = true
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(contents, "\n", { plain = true }))
				vim.bo[buf].modifiable = false
				vim.bo[buf].readonly = true
				vim.bo[buf].modified = false
				vim.bo[buf].filetype = "pkl"
				vim.lsp.buf_attach_client(buf, client.id)
			end, buf)
		end,
	})
end

return M
