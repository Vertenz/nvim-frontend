local uv = vim.uv or vim.loop -- vim.uv is preferred in 0.10+
local api = vim.api

-- Configuration
local M = {}
local config = {
	timeout = 60 * 1000, -- 1 minute in milliseconds
	debug = false,
}

-- Internal state
local timers = {}
local stopped_clients = {} -- Track which clients were stopped per buffer
local augroup_id = nil

-- Logging helper
local function log(msg)
	if config.debug then
		vim.notify("[BatterySave] " .. msg, vim.log.levels.INFO)
	end
end

-- Get buffer-specific LSP clients with better error handling
local function get_buffer_clients(bufnr)
	local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
	if not ok then
		log("Failed to get clients for buffer " .. bufnr)
		return {}
	end
	return clients or {}
end

-- Store client info before stopping
local function store_client_info(bufnr, client)
	if not stopped_clients[bufnr] then
		stopped_clients[bufnr] = {}
	end

	stopped_clients[bufnr][client.name] = {
		name = client.name,
		config = client.config,
		root_dir = client.config.root_dir,
		filetypes = client.config.filetypes,
	}
end

-- Stop LSP clients for buffer with better tracking
local function stop_lsp(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	local clients = get_buffer_clients(bufnr)
	if vim.tbl_isempty(clients) then
		return
	end

	log("Stopping " .. #clients .. " LSP client(s) for buffer " .. bufnr)

	for _, client in ipairs(clients) do
		store_client_info(bufnr, client)
		-- Use pcall to handle potential errors
		local ok, err = pcall(function()
			client.stop()
		end)
		if not ok then
			log("Error stopping client " .. client.name .. ": " .. tostring(err))
		end
	end
end

-- Start LSP servers with improved logic
local function start_lsp(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	local ft = vim.bo[bufnr].filetype
	if ft == "" or ft == nil then
		log("No filetype detected for buffer " .. bufnr)
		return
	end

	-- Check if we have stored client info to restore
	local stored = stopped_clients[bufnr]
	if stored and not vim.tbl_isempty(stored) then
		log("Restoring stored LSP clients for buffer " .. bufnr)

		for client_name, client_info in pairs(stored) do
			-- Use vim.lsp.start for modern Neovim
			local ok, err = pcall(vim.lsp.start, {
				name = client_info.name,
				cmd = client_info.config.cmd,
				root_dir = client_info.root_dir,
				settings = client_info.config.settings,
				init_options = client_info.config.init_options,
				capabilities = client_info.config.capabilities,
			}, {
				bufnr = bufnr,
			})

			if not ok then
				log("Failed to restart client " .. client_name .. ": " .. tostring(err))
			end
		end

		-- Clear stored info after successful restart
		stopped_clients[bufnr] = nil
		return
	end

	-- Fallback to automatic detection for new buffers
	log("Auto-detecting LSP servers for filetype: " .. ft)

	-- Use vim.lsp.start with automatic server detection
	local servers = vim.lsp.get_active_clients()
	for _, server_config in pairs(require("lspconfig.configs")) do
		local config_def = server_config.default_config
		if config_def and config_def.filetypes and vim.tbl_contains(config_def.filetypes, ft) then
			local ok, err = pcall(vim.lsp.start, server_config.default_config, {
				bufnr = bufnr,
			})
			if not ok then
				log("Failed to start server " .. (server_config.name or "unknown") .. ": " .. tostring(err))
			end
		end
	end
end

-- Timer management with better cleanup
local function reset_timer(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return
	end

	-- Create timer if it doesn't exist
	if not timers[bufnr] then
		local timer = uv.new_timer()
		if not timer then
			log("Failed to create timer for buffer " .. bufnr)
			return
		end

		timers[bufnr] = timer

		-- Attach cleanup handler
		local ok, err = pcall(api.nvim_buf_attach, bufnr, false, {
			on_detach = function()
				if timer then
					timer:stop()
					timer:close()
				end
				timers[bufnr] = nil
				stopped_clients[bufnr] = nil
				log("Cleaned up resources for buffer " .. bufnr)
			end,
		})

		if not ok then
			log("Failed to attach cleanup handler: " .. tostring(err))
		end
	else
		timers[bufnr]:stop()
	end

	-- Start the idle timer
	local ok, err = pcall(function()
		timers[bufnr]:start(
			config.timeout,
			0,
			vim.schedule_wrap(function()
				stop_lsp(bufnr)
			end)
		)
	end)

	if not ok then
		log("Failed to start timer: " .. tostring(err))
	end
end

-- Setup function with enhanced configuration
function M.setup(opts)
	opts = opts or {}

	-- Merge configuration
	config = vim.tbl_deep_extend("force", config, opts)

	-- Clean up existing autocmds
	if augroup_id then
		api.nvim_del_augroup_by_id(augroup_id)
	end

	augroup_id = api.nvim_create_augroup("LspBatterySave", { clear = true })

	-- Activity events that reset the timer
	api.nvim_create_autocmd({
		"TextChanged",
		"TextChangedI",
		"CursorMoved",
		"CursorMovedI",
	}, {
		group = augroup_id,
		desc = "Reset LSP idle timer on activity",
		callback = function(ev)
			reset_timer(ev.buf)
		end,
	})

	-- Insert mode entry - restart LSP if needed
	api.nvim_create_autocmd("InsertEnter", {
		group = augroup_id,
		desc = "Start LSP on insert mode entry",
		callback = function(ev)
			local bufnr = ev.buf
			local clients = get_buffer_clients(bufnr)

			if vim.tbl_isempty(clients) then
				log("No active LSP clients, starting for buffer " .. bufnr)
				start_lsp(bufnr)
			end

			reset_timer(bufnr)
		end,
	})

	-- Buffer enter events - ensure LSP is available
	api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
		group = augroup_id,
		desc = "Ensure LSP availability on buffer enter",
		callback = function(ev)
			-- Small delay to ensure buffer is fully loaded
			vim.defer_fn(function()
				if api.nvim_buf_is_valid(ev.buf) then
					reset_timer(ev.buf)
				end
			end, 100)
		end,
	})

	-- Debug info
	log("Battery save setup complete with timeout: " .. config.timeout .. "ms")
end

-- Utility functions for manual control
function M.stop_all_lsp()
	for bufnr, _ in pairs(timers) do
		stop_lsp(bufnr)
	end
end

function M.start_all_lsp()
	for bufnr, _ in pairs(timers) do
		start_lsp(bufnr)
	end
end

function M.get_status()
	local status = {}
	for bufnr, _ in pairs(timers) do
		if api.nvim_buf_is_valid(bufnr) then
			local clients = get_buffer_clients(bufnr)
			status[bufnr] = {
				active_clients = #clients,
				stored_clients = stopped_clients[bufnr] and vim.tbl_count(stopped_clients[bufnr]) or 0,
				filetype = vim.bo[bufnr].filetype,
			}
		end
	end
	return status
end

return M
