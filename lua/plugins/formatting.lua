return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>ci',
      function()
        require('conform').format {
          formatters = { 'ruff_organize_imports' },
          async = true,
        }
      end,
      mode = 'n',
      desc = '[C]ode: Organize [I]mports',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local no_format_on_save = { c = true, cpp = true }
      if no_format_on_save[vim.bo[bufnr].filetype] then
        return false
      end
      local disable_lsp_fallback = { c = true, cpp = true }
      local lsp_format_opt = disable_lsp_fallback[vim.bo[bufnr].filetype] and 'never' or 'fallback'
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- ruff_organize_imports sorts and removes unused imports, then ruff_format applies formatting.
      -- Ruff is fast enough for format-on-save (~10-50ms for most files).
      python = { 'ruff_organize_imports', 'ruff_format' },
    },
  },
}
