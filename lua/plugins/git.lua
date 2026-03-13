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
    numhl = true,
    on_attach = function(bufnr)
      local gs = require 'gitsigns'

      -- Close floating windows (e.g. a prior hunk preview) so nav_hunk
      -- doesn't try to set the cursor inside the float's small buffer.
      local function close_floats()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative ~= '' then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      -- Jump to hunk and auto-show its diff preview.
      -- nav_hunk is async, so defer the preview to let the cursor settle.
      local function nav_and_preview(direction)
        return function()
          close_floats()
          gs.nav_hunk(direction, { target = 'all' })
          vim.defer_fn(gs.preview_hunk, 100)
        end
      end

      local function reset_unstaged_hunk()
        gs.reset_hunk()
        close_floats()
        require('config.utils').refresh_neotree()
      end

      local function stage_hunk()
        gs.stage_hunk()
        require('config.utils').refresh_neotree()
      end

      local function stage_buffer()
        gs.stage_buffer()
        require('config.utils').refresh_neotree()
      end

      vim.keymap.set('n', '<A-S-K>', nav_and_preview 'prev', { buffer = bufnr, desc = 'Git Previous Hunk' })
      vim.keymap.set('n', '<A-S-J>', nav_and_preview 'next', { buffer = bufnr, desc = 'Git Next Hunk' })
      vim.keymap.set('n', '<A-S-Z>', reset_unstaged_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
      vim.keymap.set('n', '<leader>gr', reset_unstaged_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
      vim.keymap.set('n', '<leader>gap', stage_hunk, { buffer = bufnr, desc = 'Git Stage/Unstage Patch' })
      vim.keymap.set('n', '<leader>gaa', stage_buffer, { buffer = bufnr, desc = 'Git Stage File' })
      vim.keymap.set('n', '<leader>gp', gs.preview_hunk_inline, { buffer = bufnr, desc = 'Git Preview Hunk' })

      -- Toggle blame: close if open, otherwise open.
      vim.keymap.set('n', '<leader>gb', function()
        if not require('config.utils').close_blame() then
          gs.blame()
        end
      end, { buffer = bufnr, desc = 'Toggle Git Blame' })
    end,
  },
}
