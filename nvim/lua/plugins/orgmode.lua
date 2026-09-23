return {
	"orgmode",
	for_cat = "extras",
	lazy = false,
	after = function()
		local notes_dir = vim.fn.expand("~/Documents/Org")
		local config = {
			org_todo_keywords = { "TODO(t)", "NEXT(n)", "WAIT(w)", "|", "DONE(d)", "CANCELLED(c)" },
			org_log_done = "time",
			org_log_into_drawer = "LOGBOOK",
			org_startup_indented = true,
			org_hide_emphasis_markers = true,
			org_edit_src_content_indentation = 4,
		}

		if vim.fn.isdirectory(notes_dir) == 1 then
			local function agenda_files()
				local files = {}
				for _, file in ipairs(vim.fn.globpath(notes_dir, "**/*.org", false, true)) do
					local relative = file:sub(#notes_dir + 2)
					local excluded = relative == "README.org" or relative == "index.org" or relative == "setup.org"
					for part in relative:gmatch("[^/]+") do
						if part == "templates" or part == "archive" or part == ".git" then
							excluded = true
							break
						end
					end
					if not excluded then
						table.insert(files, file)
					end
				end
				return files
			end

			config.org_agenda_files = agenda_files()
			config.mappings = { global = { org_agenda = false } }
			config.org_default_notes_file = notes_dir .. "/inbox.org"
			config.org_archive_location = "archive/%s_archive::"
			config.org_capture_templates = {
				t = {
					description = "Task",
					template = "* TODO %?\n  %U",
					target = notes_dir .. "/inbox.org",
					headline = "Unprocessed",
					properties = { empty_lines = 1 },
				},
				n = {
					description = "Inbox note",
					template = "* %?\n  %U",
					target = notes_dir .. "/inbox.org",
					headline = "Unprocessed",
					properties = { empty_lines = 1 },
				},
				j = {
					description = "Journal",
					template = "* %U %?",
					target = notes_dir .. "/journal.org",
					datetree = {
						tree_type = "custom",
						tree = {
							{ format = "Journal", pattern = "^(Journal)$", order = { 1 } },
							{ format = "%Y", pattern = "^(%d%d%d%d)$", order = { 1 } },
							{ format = "%Y-%m %B", pattern = "^(%d%d%d%d)%-(%d%d).*$", order = { 1, 2 } },
							{ format = "%Y-%m-%d %A", pattern = "^(%d%d%d%d)%-(%d%d)%-(%d%d).*$", order = { 1, 2, 3 } },
						},
					},
					properties = { empty_lines = 1 },
				},
			}
			vim.keymap.set("n", "<leader>oa", function()
				local org = require("orgmode")
				org.files.paths = agenda_files()
				org.files:load_sync(true, 20000)
				org.agenda:prompt()
			end, { desc = "Org agenda" })

			vim.keymap.set("n", "<leader>oI", function()
				vim.cmd.edit(vim.fn.fnameescape(notes_dir .. "/index.org"))
			end, { desc = "Open notes index" })
			vim.keymap.set("n", "<leader>os", function()
				Snacks.picker.grep({ dirs = { notes_dir } })
			end, { desc = "Search Org notes" })
		end

		require("orgmode").setup(config)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
				vim.opt_local.spell = true
				vim.opt_local.colorcolumn = ""
				vim.opt_local.conceallevel = 2
			end,
		})
	end,
}
