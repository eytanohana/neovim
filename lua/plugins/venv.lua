-- Virtual environment selector for Python.
-- Discovers .venv, uv, poetry, conda, pyenv envs and updates LSP + DAP.
return {
  'linux-cultist/venv-selector.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  ft = 'python',
  keys = {
    {
      '<leader>cv',
      function()
        vim.cmd 'VenvSelect'
      end,
      ft = 'python',
      desc = '[C]ode: Select [V]env',
    },
  },
  opts = {},
}
