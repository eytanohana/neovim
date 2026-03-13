return {
  {
    'Kicamon/markdown-table-mode.nvim',
    config = function()
      require('markdown-table-mode').setup()

      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*markdown',
        callback = function()
          vim.cmd 'Mtm'
        end,
      })
    end,
  },
}
