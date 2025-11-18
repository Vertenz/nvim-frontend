local vue_language_server_path = vim.fn.stdpath("data")
	.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
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
	filetypes = tsserver_filetypes,
}

local ts_ls_config = {
	init_options = {
		plugins = {
			vue_plugin,
		},
	},
	filetypes = tsserver_filetypes,
}

local vue_ls_config = {
	on_init = function(client)
		client.handlers["tsserver/request"] = function(_, result, context)
			-- Ищем vtsls
			local vtsls_list = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
			local ts_client = (vtsls_list and #vtsls_list > 0) and vtsls_list[1] or nil

			-- Фоллбэк на ts_ls (некоторые используют typescript-tools c именем ts_ls)
			if not ts_client then
				local tsls_list = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })
				if tsls_list and #tsls_list > 0 then
					ts_client = tsls_list[1]
				end
			end

			if not ts_client then
				vim.notify(
					"Could not find `vtsls` or `ts_ls` LSP client; `vue_ls` will not work without it.",
					vim.log.levels.ERROR
				)
				return
			end

			local unpack_ = table.unpack or unpack

			-- result может прийти как { {id, command, payload} } или как {id, command, payload}
			local id, command, payload
			if type(result) == "table" and type(result[1]) == "table" then
				id, command, payload = unpack_(result[1])
			else
				id, command, payload = unpack_(result)
			end

			ts_client:exec_cmd({
				title = "vue_request_forward", -- метка для UI
				command = "typescript.tsserverRequest",
				arguments = { command, payload },
			}, { bufnr = context.bufnr }, function(_, r)
				local response = r and r.body
				-- Не прерываем цепочку даже при ошибке, чтобы не утекала память
				local response_data = { { id, response } }

				---@diagnostic disable-next-line: param-type-mismatch
				client:notify("tsserver/response", response_data)
			end)
		end
	end,
}

vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.enable({ "vtsls", "vue_ls" })
