local prompts = {
	-- Code related prompts
	Explain = "Please explain how the following code works.",
	Review = "Please review the following code and provide suggestions for improvement.",
	Tests = "Please explain how the selected code works, then generate unit tests for it.",
	Refactor = "Please refactor the following code to improve its clarity and readability.",
	FixCode = "Please fix the following code to make it work as intended.",
	FixError = "Please explain the error in the following text and provide a solution.",
	BetterNamings = "Please provide better names for the following variables and functions.",
	Documentation = "Please provide documentation for the following code.",
	SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
	SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
	-- Text related prompts
	Summarize = "Please summarize the following text.",
	Spelling = "Please correct any grammar and spelling errors in the following text.",
	Wording = "Please improve the grammar and wording of the following text.",
	Concise = "Please rewrite the following text to make it more concise.",
}

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		lazy = false,
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
			"gptlang/lua-tiktoken",
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			question_header = "## User ",
			answer_header = "## Copilot ",
			error_header = "## Error ",
			prompts = prompts,
			model = "claude-3.7-sonnet",
			mappings = {
				-- Use tab for completion
				complete = {
					detail = "Use @<S+Tab> or /<Tab> for options.",
					insert = "<S-Tab>",
				},
				-- Close the chat
				close = {
					normal = "q",
					insert = "<C-c>",
				},
				-- Reset the chat buffer
				reset = {
					normal = "<C-x>",
					insert = "<C-x>",
				},
				-- Submit the prompt to Copilot
				submit_prompt = {
					normal = "<CR>",
					insert = "<C-CR>",
				},
				-- Accept the diff
				accept_diff = {
					normal = "<C-y>",
					insert = "<C-y>",
				},
				-- Show help
				show_help = {
					normal = "g?",
				},
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")

			-- Add project context file to options if it exists
			opts.context_provider = opts.context_provider or {}
			opts.context_provider.project_context = {
				get_context = function()
					local context_file = vim.fn.findfile(".context", vim.fn.getcwd() .. ";")
					if context_file ~= "" and vim.fn.filereadable(context_file) == 1 then
						local content = table.concat(vim.fn.readfile(context_file), "\n")
						return "Project Context:\n" .. content
					end
					return ""
				end,
			}

			local function load_context_file()
				local context_file = vim.fn.findfile(".context", vim.fn.getcwd() .. ";")
				if context_file ~= "" and vim.fn.filereadable(context_file) == 1 then
					local f = io.open(context_file, "r")
					if f then
						local content = f:read("*all")
						f:close()
						-- Set the context as a Copilot variable
						vim.g.copilot_context = content
						vim.notify("Loaded Copilot context from " .. context_file)
						return content
					end
				end
				return ""
			end

			opts.context_provider = opts.context_provider or {}
			opts.context_provider.project_context = {
				get_context = function()
					return vim.g.copilot_context or load_context_file()
				end,
			}

			chat.setup(opts)

			-- Restore CopilotChatBuffer
			vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = select.buffer })
			end, { nargs = "*", range = true })

			-- Custom buffer for CopilotChat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true
				end,
			})
		end,

		-- keys
		keys = {
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt({
						context = {
							"buffers",
							"project_context",
						},
					})
				end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>ac",
				function()
					require("CopilotChat").open({
						context = {
							"buffers",
							"project_context",
						},
					})
				end,
				desc = "CopilotChat – Quick chat",
			},
		},
	},
}
