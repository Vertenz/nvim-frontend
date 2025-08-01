return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 1500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			javascript = { "prettierd", "eslint_d" },
			vue = { "stylelint", "eslint_d" },
			react = { "stylelint", "prettierd", "eslint_d" },
			typescriptreact = { "stylelint", "prettierd", "eslint_d" },
			javascriptreact = { "stylelint", "prettierd", "eslint_d" },
			typescript = { "prettierd", "eslint_d" },
			json = { "prettierd", "eslint_d" },
			html = { "prettierd", "eslint_d" },
			css = { "stylelint", "prettierd", "eslint_d" },
			scss = { "eslint_d", "prettierd", "stylelint" },
			less = { "stylelint", "prettierd", "eslint_d" },
			postcss = { "stylelint", "prettierd", "eslint_d" },
		},
	},
}
