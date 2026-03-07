return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    { '<leader>q', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xx', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
    { '<leader>xX', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    { '<leader>xQ', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
  },
  opts = {},
}
