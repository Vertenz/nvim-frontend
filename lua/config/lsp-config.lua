local vue_language_server_path = vim.fn.expand("$MASON/packages/vue-language-server")
	.. "/node_modules/@vue/language-server"
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}
local vtsls_config = {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
}

local vue_ls_config = {
	on_init = function(client)
		client.handlers["tsserver/request"] = function(_, result, context)
			local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
			if #clients == 0 then
				vim.notify(
					"Could not found `vtsls` lsp client, vue_lsp would not work without it.",
					vim.log.levels.ERROR
				)
				return
			end
			local ts_client = clients[1]

			local param = unpack(result)
			local id, command, payload = unpack(param)
			ts_client:exec_cmd({
				title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
				command = "typescript.tsserverRequest",
				arguments = {
					command,
					payload,
				},
			}, { bufnr = context.bufnr }, function(_, r)
				local response_data = { { id, r.body } }
				---@diagnostic disable-next-line: param-type-mismatch
				client:notify("tsserver/response", response_data)
			end)
		end
	end,
}

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

vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.enable({ "vtsls", "vue_ls" })
vim.lsp.config("somesass_ls", somesass_ls)
vim.lsp.config("css_variables", css_variables)
vim.lsp.config("prettierd", prettierd_config)
