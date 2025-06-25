local uv = vim.loop
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

-- внутренние переменные
local idle_ms = 60 * 1000 -- 1 минута
local timers = {} -- по буферам

-- остановить все LSP-клиенты в буфере
local function stop_lsp(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		client.stop()
	end
end

-- запустить LSP-сервера под этот буфер
local function start_lsp(bufnr)
	local ft = vim.bo[bufnr].filetype
	if ft == "" then
		return
	end

	for _, name in ipairs(util.available_servers()) do
		local cfg = lspconfig[name]
		if cfg then
			local dconf = (cfg.document_config and cfg.document_config.default_config) or cfg.default_config
			if dconf and dconf.filetypes and vim.tbl_contains(dconf.filetypes, ft) then
				cfg.manager.try_add(bufnr)
			end
		end
	end
end

-- сбросить или создать таймер простоя
local function reset_timer(bufnr)
	if not timers[bufnr] then
		local t = uv.new_timer()
		timers[bufnr] = t
		-- при выгрузке буфера очищаем таймер
		vim.api.nvim_buf_attach(bufnr, false, {
			on_detach = function()
				t:stop()
				t:close()
				timers[bufnr] = nil
			end,
		})
	else
		timers[bufnr]:stop()
	end

	timers[bufnr]:start(
		idle_ms,
		0,
		vim.schedule_wrap(function()
			stop_lsp(bufnr)
		end)
	)
end

-- точка входа
local M = {}

--- Настроить автокоманды
-- @param opts.timeout — таймаут простоя в мс
function M.setup(opts)
	opts = opts or {}
	idle_ms = opts.timeout or idle_ms

	local aug = vim.api.nvim_create_augroup("LspIdleControl", { clear = true })

	-- при любой активности сбрасываем таймер
	vim.api.nvim_create_autocmd({
		"TextChanged",
		"TextChangedI",
		"InsertEndter",
	}, {
		group = aug,
		callback = function(ev)
			reset_timer(ev.buf)
		end,
	})

	-- при входе в Insert / при чтении/записи/входе в буфер — рестартим LSP, если нужно
	vim.api.nvim_create_autocmd({
		"InsertEnter",
	}, {
		group = aug,
		callback = function(ev)
			local bufnr = ev.buf
			if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufnr })) then
				start_lsp(bufnr)
			end
			reset_timer(bufnr)
		end,
	})
end

return M
