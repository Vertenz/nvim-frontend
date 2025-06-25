return {
  {
    'neoclide/coc.nvim',
    branch = 'release',
    build = 'npm install',
    config = function()
      require 'settings.coc'
    end,
  },
}
