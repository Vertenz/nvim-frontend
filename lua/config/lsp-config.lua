local somesass_ls = {
	filetypes = { "scss", "sass", "css", "vue", "tsx", "jsx" },
}

local css_variables = {
	filetypes = { "css", "scss", "sass", "less", "vue" },
	init_options = {
		cssVariables = {
			enabled = true,
			workspaceFolder = vim.fn.getcwd(),
		},
	},
}

local prettierd_config = {
	filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
}

vim.lsp.config("somesass_ls", somesass_ls)
vim.lsp.config("css_variables", css_variables)
vim.lsp.config("prettierd", prettierd_config)
