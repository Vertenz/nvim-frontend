return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		local function open_nvim_tree(data)
			if vim.fn.isdirectory(data.file) == 1 then
				vim.cmd.cd(data.file)
				require("nvim-tree.api").tree.open()
			end
		end

		vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

		require("nvim-tree").setup({
			sort_by = "case_sensitive",
			view = {
				width = 30,
				side = "left",
				preserve_window_proportions = true,
				number = true,
				relativenumber = true,
			},
			renderer = {
				group_empty = true,
				highlight_opened_files = "all",
				highlight_git = "name",
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
			filters = {
				dotfiles = false,
				custom = { ".DS_Store" },
			},
			git = {
				enable = true,
				ignore = false,
			},
			actions = {
				open_file = {
					quit_on_open = true,
					resize_window = true,
				},
			},
		})
	end,
}
