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
      local gs = require 'gitsigns'

      local function close_floats()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative ~= '' then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      local function nav_and_preview(direction)
        return function()
          close_floats()
          gs.nav_hunk(direction)
          vim.defer_fn(function()
            gs.preview_hunk()
          end, 100)
        end
      end

      vim.keymap.set('n', '<A-S-K>', nav_and_preview('prev'), { buffer = bufnr, desc = 'Git Previous Hunk' })
      vim.keymap.set('n', '<A-S-J>', nav_and_preview('next'), { buffer = bufnr, desc = 'Git Next Hunk' })
      vim.keymap.set('n', '<A-S-Z>', gs.reset_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
      vim.keymap.set('n', '<leader>gb', gs.blame, { buffer = bufnr, desc = 'Git Blame' })
    end,
  },
}
