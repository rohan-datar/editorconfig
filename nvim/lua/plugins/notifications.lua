return {
	"fidget.nvim",
	for_cat = "core",
	event = "DeferredUIEnter",
	after = function()
		local default_config = require("fidget.notification").default_config
		default_config.name = nil
		default_config.icon = nil
		require("fidget").setup({
			notification = {
				override_vim_notify = true,
				configs = {
					default = default_config,
				},
				window = {
					winblend = 0,
				},
			},
			progress = {
				display = {
					done_icon = "✓",
				},
			},
		})

		local notification_history = function()
			-- create a bottom split via Snacks.win
			local Win = (rawget(_G, "Snacks") and Snacks.win) or require("snacks.win")
			local win = Win({
				style = "split", -- use a split instead of a float
				relative = "editor", -- split relative to the full editor
				position = "bottom", -- bottom split (like your NUI config)
				height = 0.25, -- 25% of the editor height
				border = "single",
				title = "Notifications",
				ft = "fidget_history", -- nice-to-have filetype tag
				fixbuf = true, -- keep this buffer pinned in the split
				keys = {
					q = { "close", mode = "n", desc = "Close" }, -- Snacks action
					["<Esc>"] = { "close", mode = "n" },
					["g?"] = { "toggle_help", mode = "n", desc = "Help" },
				},
				wo = { -- window options
					wrap = false,
					cursorline = false,
					spell = false,
				},
				bo = { -- buffer options
					buftype = "nofile",
					bufhidden = "wipe",
					swapfile = false,
				},
			})

			win:show() -- open the split

			-- pull history from fidget
			local notifications = require("fidget.notification").get_history() or {}

			local buf = win.buf
			local ns = vim.api.nvim_create_namespace("FidgetHistory")
			local lines = {}
			local hl = {} -- collect {row, group, col_start, col_end}

			local row = 0
			for _, item in ipairs(notifications) do
				local date = vim.fn.strftime("%c", item.last_updated)
				local group = (item.group_name and #item.group_name > 0) and item.group_name or nil
				local annote = (item.annote and #item.annote > 0) and item.annote or nil
				local is_multi = item.message and item.message:find("\n") ~= nil

				-- build the header line
				local parts = { date }
				if group then
					table.insert(parts, group)
				end
				if annote then
					table.insert(parts, "|")
					table.insert(parts, annote)
				end
				if not is_multi and item.message and #item.message > 0 then
					table.insert(parts, item.message)
				end
				local header = table.concat(parts, " ")

				table.insert(lines, header)

				-- highlights on the header
				local col = 0
				table.insert(hl, { row, "Comment", col, col + #date })
				col = col + #date
				if group then
					col = col + 1
					table.insert(hl, { row, "Special", col, col + #group })
					col = col + #group
				end
				if annote then
					col = col + 1 -- space before '|'
					table.insert(hl, { row, "Comment", col, col + 1 })
					col = col + 2 -- '|' and following space
					table.insert(hl, { row, item.style or "Normal", col, col + #annote })
					col = col + #annote
				end
				if not is_multi and item.message and #item.message > 0 then
					col = col + 1
					table.insert(hl, { row, "Special", col, col + #item.message })
				end

				row = row + 1

				-- multiline body
				if is_multi then
					for _, m in ipairs(vim.split(item.message, "\n", { plain = true })) do
						table.insert(lines, "\t" .. m)
						row = row + 1
					end
				end
			end

			-- write lines and apply highlights
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			for _, h in ipairs(hl) do
				vim.hl.range(buf, ns, h[2], { h[1], h[3] }, { h[1], h[4] })
			end

			-- lock the buffer
			vim.bo[buf].modifiable = false
			vim.bo[buf].readonly = true
		end

		vim.api.nvim_create_user_command("Notifications", notification_history, {
			desc = "Fidget history",
		})
	end,
}
