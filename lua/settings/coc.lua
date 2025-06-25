function _G.check_back_space()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

vim.keymap.set('n', '<leader>qf', '<Plug>(coc-fix-current)', { silent = true })
vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })
vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1
      and vim.fn["coc#pum#confirm"]()
      or "\r"
end, opts)
