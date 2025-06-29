return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"vue",
			"javascript",
			"typescript",
			"tsx",
			"scss",
			"css",
			"python",
		},
		auto_install = true,
		sync_install = false,
		highlight = { enable = true, additional_vim_regex_highlighting = false },
		indent = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
		vim.opt.foldenable = true
		vim.opt.foldlevel = 99

		local km = vim.keymap.set
		km("n", "<leader>ws", "zc", { desc = "Close fold" })
		km("n", "<leader>we", "zo", { desc = "Open fold" })
		km("n", "<leader>wS", "zM", { desc = "Close all folds" })
		km("n", "<leader>wE", "zR", { desc = "Open all folds" })
		km("n", "]f", "]z", { desc = "Next fold" })
		km("n", "[f", "[z", { desc = "Previous fold" })
	end,
}
