local vue_language_server = vim.fn.expand("$MASON/packages/vue-language-server") .. "/node_modules/@vue/language-server"

local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server,
	languages = { "vue" },
	configNamespace = "typescript",
}

local vue_ls_config = {
	init_options = {
		typescript = {
			tsserverRequestCommand = {
				"typescript.tsserverRequest",
				"typescript.tsserverResponse",
			},
		},
	},
	on_init = function(client)
		client.handlers["typescript.tsserverRequest"] = function(_, result, context)
			local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
			if #clients == 0 then
				vim.notify("Could not found `vtsls` lsp client, vue_lsp would not work with it.", vim.log.levels.ERROR)
				return
			end
			local ts_client = clients[1]

			local param = unpack(result)
			local command, payload, id = unpack(param)
			ts_client:exec_cmd({
				command = "typescript.tsserverRequest",
				arguments = {
					command,
					payload,
				},
			}, { bufnr = context.bufnr }, function(_, r)
				local response_data = { { id, r.body } }
				---@diagnostic disable-next-line: param-type-mismatch
				client:notify("typescript.tsserverResponse", response_data)
			end)
		end
	end,
}

local vtsls_config = {
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	settings = {
		vtsls = { tsserver = { globalPlugins = {} } },
	},
	before_init = function(params, config)
		local result = vim.system({ "npm", "query", "#vue" }, { cwd = params.workspaceFolders[1].name, text = true })
			:wait()
		if result.stdout ~= "[]" then
			local vuePluginConfig = {
				name = "@vue/typescript-plugin",
				location = vue_language_server,
				languages = { "vue" },
				configNamespace = "typescript",
				enableForWorkspaceTypeScriptVersions = true,
			}
			table.insert(config.settings.vtsls.tsserver.globalPlugins, vuePluginConfig)
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
vim.lsp.config("somesass_ls", somesass_ls)
vim.lsp.config("css_variables", css_variables)
vim.lsp.config("prettierd", prettierd_config)
