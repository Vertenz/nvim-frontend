local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end, { desc = "Add file to harpoon" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function()
	harpoon:list():prev()
end, { desc = "Go to previous harpoon file" })

vim.keymap.set("n", "<leader>hn", function()
	harpoon:list():next()
end, { desc = "Go to next harpoon file" })

-- Remove current file from Harpoon list
vim.keymap.set("n", "<leader>hr", function()
	harpoon:list():remove()
end, { desc = "Remove file from harpoon" })

-- Remove all files from Harpoon list
vim.keymap.set("n", "<leader>hc", function()
	harpoon:list():clear()
end, { desc = "Clear harpoon list" })

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

vim.keymap.set("n", "<C-h>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })
