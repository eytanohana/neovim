return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VimEnter',
  config = function()
    local bufferline = require 'bufferline'

    local function force_delete(bufnum)
      vim.api.nvim_buf_delete(bufnum, { force = true })
    end

    bufferline.setup {
      options = {
        mode = 'buffers',
        style_preset = bufferline.style_preset.default,
        themable = true,

        close_command = force_delete,
        right_mouse_command = force_delete,
        left_mouse_command = 'buffer %d',
        middle_mouse_command = force_delete,

        indicator = {
          icon = '▎',
          style = 'icon',
        },

        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',

        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return icon .. count
        end,

        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            highlight = 'Directory',
            text_align = 'left',
            separator = true,
          },
        },

        custom_filter = function(buf)
          local dominated = { qf = true, help = true, prompt = true }
          return not dominated[vim.bo[buf].buftype]
        end,

        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        duplicates_across_groups = true,

        persist_buffer_sort = true,
        separator_style = 'slant',
        enforce_regular_tabs = false,
        always_show_bufferline = true,

        sort_by = 'insert_at_end',

        hover = {
          enabled = true,
          delay = 150,
          reveal = { 'close' },
        },
      },
    }
  end,
}
