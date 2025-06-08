return {
    {
        'mbbill/undotree',
        vim.keymap.set('n', '<C-U>', vim.cmd.UndotreeToggle, { noremap = true, silent = true }),
    },
}
