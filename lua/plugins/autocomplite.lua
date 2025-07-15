-- return { -- Autocompletion
-- 	"saghen/blink.cmp",
-- 	event = "VimEnter",
-- 	version = "1.*",
-- 	dependencies = {
-- 		-- Snippet Engine & its associated nvim-cmp source
-- 		-- {
-- 		-- 	"L3MON4D3/LuaSnip",
-- 		-- 	version = "2.*",
-- 		-- 	build = (function()
-- 		-- 		-- Build Step is needed for regex support in snippets.
-- 		-- 		-- This step is not supported in many windows environments.
-- 		-- 		-- Remove the below condition to re-enable on windows.
-- 		-- 		if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
-- 		-- 			return
-- 		-- 		end
-- 		-- 		return "make install_jsregexp"
-- 		-- 	end)(),
-- 		-- 	dependencies = {
-- 		-- 		-- `friendly-snippets` contains a variety of premade snippets.
-- 		-- 		--    See the README about individual language/framework/plugin snippets:
-- 		-- 		--    https://github.com/rafamadriz/friendly-snippets
-- 		-- 		{
-- 		-- 			"rafamadriz/friendly-snippets",
-- 		-- 			config = function()
-- 		-- 				require("luasnip.loaders.from_vscode").lazy_load({
-- 		-- 					exclude = { "javascript", "typescript", "vue", "html", "css", "scss", "javascriptreact" },
-- 		-- 				})
-- 		-- 				require("luasnip.loaders.from_vscode").lazy_load({
-- 		-- 					paths = { vim.fn.stdpath("config") .. "/snippets" },
-- 		-- 				})
-- 		-- 			end,
-- 		-- 		},
-- 		-- 	},
-- 		-- 	opts = {},
-- 		-- },
-- 		-- "folke/lazydev.nvim",
-- 		-- -- 'saadparwaiz1/cmp_luasnip',
-- 		-- "wkillerud/some-sass",
-- 	},

-- 	--- @module 'blink.cmp'
-- 	opts = {
-- 		keymap = {
-- 			-- 'default' (recommended) for mappings similar to built-in completions
-- 			--   <c-y> to accept ([y]es) the completion.
-- 			--    This will auto-import if your LSP supports it.
-- 			--    This will expand snippets if the LSP sent a snippet.
-- 			-- 'super-tab' for tab to accept
-- 			-- 'enter' for enter to accept
-- 			-- 'none' for no mappings
-- 			--
-- 			-- For an understanding of why the 'default' preset is recommended,
-- 			-- you will need to read `:help ins-completion`
-- 			--
-- 			-- No, but seriously. Please read `:help ins-completion`, it is really good!
-- 			--
-- 			-- All presets have the following mappings:
-- 			-- <tab>/<s-tab>: move to right/left of your snippet expansion
-- 			-- <c-space>: Open menu or open docs if already open
-- 			-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
-- 			-- <c-e>: Hide menu
-- 			-- <c-k>: Toggle signature help
-- 			--
-- 			-- See :h blink-cmp-config-keymap for defining your own keymap
-- 			preset = "enter",

-- 			-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
-- 			--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
-- 		},

-- 		appearance = {
-- 			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
-- 			-- Adjusts spacing to ensure icons are aligned
-- 			nerd_font_variant = "mono",
-- 		},

-- 		completion = {
-- 			-- By default, you may press `<c-space>` to show the documentation.
-- 			-- Optionally, set `auto_show = true` to show the documentation after a delay.
-- 			documentation = { auto_show = false, auto_show_delay_ms = 500 },
-- 		},

-- 		sources = {
-- 			default = { "lsp", "path", "snippets", "lazydev" },
-- 			providers = {
-- 				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
-- 			},
-- 		},

-- 		snippets = { preset = "luasnip" },

-- 		-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
-- 		-- which automatically downloads a prebuilt binary when enabled.
-- 		--
-- 		-- By default, we use the Lua implementation instead, but you may enable
-- 		-- the rust implementation via `'prefer_rust_with_warning'`
-- 		--
-- 		-- See :h blink-cmp-config-fuzzy for more information
-- 		fuzzy = { implementation = "lua" },

-- 		-- Shows a signature help window while you type arguments for a function
-- 		signature = { enabled = true },
-- 	},
-- }
return {
	'saghen/blink.cmp',
	-- optional: provides snippets for the snippet source
	dependencies = { 'rafamadriz/friendly-snippets' },

	-- use a release tag to download pre-built binaries
	version = '1.*',
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = 'default' },

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = 'mono'
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = { documentation = { auto_show = false } },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer' },
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" }
	},
	opts_extend = { "sources.default" }
}
