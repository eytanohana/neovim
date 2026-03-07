-- outline.nvim: LSP-powered symbol outline sidebar.
return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>to', '<cmd>Outline<cr>', desc = '[T]oggle [O]utline' },
  },
  opts = {
    outline_window = {
      position = 'right',
      width = 25,
      auto_close = false,
    },
    symbol_folding = {
      autofold_depth = 1,
      auto_unfold = { hovered = true, only = true },
    },
  },
}
