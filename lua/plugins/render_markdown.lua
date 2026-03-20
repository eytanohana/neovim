-- Rich in-buffer Markdown rendering (icons, code blocks, tables, callouts).
-- See https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Optional: `:TSInstall latex` after installing the `tree-sitter` CLI for formula rendering.
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      -- mini.nvim (already in ui.lua) provides mini.icons for code-block language icons
      'echasnovski/mini.nvim',
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- In-process completions for checkboxes / callouts (works with blink.cmp)
      completions = { lsp = { enabled = true } },
      -- First attach in a lazy-loaded buffer can leave stale highlights
      restart_highlighter = true,
      -- anti_conceal: when true, hides rendered virtual text on/near the cursor line so you can
      -- edit raw syntax. When false, the pretty view stays on the cursor line ("always pretty").
      anti_conceal = {
        enabled = false,
        -- Used when anti_conceal is enabled (toggle with <leader>ma)
        above = 1,
        below = 1,
      },
      latex = {
        enabled = true,
      },
    },
    config = function(_, opts)
      -- Code-block icons (same suite as mini.ai / mini.surround in ui.lua)
      require('mini.icons').setup()
      require('render-markdown').setup(opts)

      ---@param enabled boolean
      local function set_anti_conceal(enabled)
        local state = require('render-markdown.state')
        state.config.anti_conceal.enabled = enabled
        for _, buf_cfg in pairs(state.cache) do
          buf_cfg.anti_conceal.enabled = enabled
        end
        for buf in pairs(state.cache) do
          require('render-markdown').render { buf = buf }
        end
      end

      vim.keymap.set('n', '<leader>mt', function()
        require('render-markdown').buf_toggle()
      end, { desc = 'Toggle markdown render (buffer)' })

      vim.keymap.set('n', '<leader>mp', function()
        require('render-markdown').preview()
      end, { desc = 'Markdown preview (side panel)' })

      -- Toggle "cursor line shows raw" (anti-conceal) vs always-pretty on the cursor line
      vim.keymap.set('n', '<leader>ma', function()
        local ac = require('render-markdown.state').config.anti_conceal
        set_anti_conceal(not ac.enabled)
      end, { desc = 'Toggle cursor-line raw (anti-conceal)' })
    end,
  },
}
