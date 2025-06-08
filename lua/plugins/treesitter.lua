return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    main = 'nvim-treesitter.configs',
    opts = {
        ensure_installed = {
            'bash',
            'diff',
            'html',
            'lua',
            'luadoc',
            'markdown',
            'markdown_inline',
            'query',
            'vim',
            'vimdoc',
            'vue',
            'javascript',
            'typescript',
            'tsx',
            'scss',
            'css',
            'python',
        },
        auto_install = true,
        highlight = {
            enable = true,
        },
    }
}
