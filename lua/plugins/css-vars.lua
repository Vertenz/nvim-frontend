return {
	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPre",
		config = function()
			require("nvim-highlight-colors").setup({
				render = "background",
				enable_var_usage = true,
			})
		end,
	},
}
