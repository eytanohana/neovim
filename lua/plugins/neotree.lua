return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      add_blank_line_at_top = true,
      close_if_last_window = true,
      open_files_do_not_replace_types = { 'terminal', 'Trouble', 'qf' },
      window = {
        position = 'left',
        width = 35,
        mappings = {
          ['l'] = 'open',
          ['h'] = 'close_node',
        },
      },
      filesystem = {
        follow_current_file = { enabled = true, leave_dirs_open = false },
        filtered_items = { visible = true },
      },
    }
    vim.keymap.set('n', '<A-0>', ':Neotree toggle reveal_force_cwd<CR>', { silent = true })
  end,
}
