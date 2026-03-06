return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local function next_prev_hunk(func)
        return function()
          func()
          require('gitsigns').preview_hunk()
        end
      end
      vim.keymap.set('n', '<A-S-K>', next_prev_hunk(require('gitsigns').prev_hunk), { buffer = bufnr, desc = 'Git Previous Hunk' })
      vim.keymap.set('n', '<A-S-J>', next_prev_hunk(require('gitsigns').next_hunk), { buffer = bufnr, desc = 'Git Next Hunk' })
      vim.keymap.set('n', '<A-S-Z>', require('gitsigns').reset_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
      vim.keymap.set('n', '<leader>gb', require('gitsigns').blame, { buffer = bufnr, desc = 'Git Blame' })
    end,
  },
}
