-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- for next switch leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-- buffer clipboard
vim.opt.clipboard:append("unnamedplus")

--clipboard optionally enable 24-bit colour
vim.opt.termguicolors = true

-- Make line numbers default
vim.opt.number = true
-- switch numbers depends on mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	pattern = "*",
	callback = function()
		vim.opt.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
	pattern = "*",
	callback = function()
		vim.opt.relativenumber = true
	end,
})

-- autosave
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "TabLeave" }, {
	pattern = "*",
	callback = function()
		if vim.bo.modified then
			vim.cmd("silent! write")
		end
	end,
})

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 350

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- tab
vim.opt.tabstop = 1
vim.opt.shiftwidth = 2

-- Show full virtual text
-- Show all virtual text under the cursor in a floating window (Neovim 0.11+)
local function show_virtual_text()
	local api = vim.api
	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local line = cursor[1] - 1

	local namespaces = api.nvim_get_namespaces()
	local messages = {}

	-- Collect extmarks with virt_text only (0.10+ feature)
	for _, ns_id in pairs(namespaces) do
		local extmarks = api.nvim_buf_get_extmarks(bufnr, ns_id, { line, 0 }, { line, -1 }, { details = true })
		for _, extmark in ipairs(extmarks) do
			local details = extmark[4]
			if details.virt_text then
				for _, chunk in ipairs(details.virt_text) do
					local text = vim.trim(chunk[1])
					if text ~= "" then
						messages[#messages + 1] = text
					end
				end
			end
			-- Optionally, collect virt_lines (0.11+)
			if details.virt_lines then
				for _, vline in ipairs(details.virt_lines) do
					for _, chunk in ipairs(vline) do
						local vtext = vim.trim(chunk[1])
						if vtext ~= "" then
							messages[#messages + 1] = vtext
						end
					end
				end
			end
		end
	end

	-- Remove duplicates and empty lines
	local seen, lines = {}, {}
	for _, msg in ipairs(messages) do
		if msg ~= "" and not seen[msg] then
			table.insert(lines, msg)
			seen[msg] = true
		end
	end

	if #lines == 0 then
		vim.notify("No virtual text on this line", vim.log.levels.INFO)
		return
	end

	-- Determine optimal width
	local max_width = 0
	for _, l in ipairs(lines) do
		max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
	end
	max_width = math.min(max_width, math.floor(vim.o.columns * 0.8))

	-- Create floating window (popup)
	local float_buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)

	local win = api.nvim_open_win(float_buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = max_width,
		height = #lines,
		style = "minimal",
		border = "rounded",
		noautocmd = true,
	})

	-- Optional: close on keypress or mouse
	api.nvim_create_autocmd("BufLeave", {
		buffer = float_buf,
		callback = function()
			if api.nvim_win_is_valid(win) then
				api.nvim_win_close(win, true)
			end
		end,
	})
	-- Close popup on Escape
	api.nvim_buf_set_keymap(float_buf, "n", "<Esc>", "<cmd>bd!<CR>", { nowait = true, noremap = true, silent = true })
end

vim.keymap.set("n", "<leader>vt", show_virtual_text, { desc = "Show virtual text under cursor" })
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- spell
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "ru_ru" }
vim.opt.spelloptions = "camel"

-- lazy.nvim
require("config.lazy")

-- vue
require("config.vue3-lps")

-- main-lsp
require("config.lsp-config")

-- harpoon
require("config.harpoon-setup")
