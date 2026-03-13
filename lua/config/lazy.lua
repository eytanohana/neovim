local plugins = {
  require 'plugins.git',
  require 'plugins.telescope',
  require 'plugins.completion', -- before lsp so blink.cmp is loaded and get_lsp_capabilities() is available
  require 'plugins.lsp',
  require 'plugins.formatting',
  require 'plugins.treesitter',
  require 'plugins.venv',
  require 'plugins.debug',
  require 'plugins.test',
  require 'plugins.indent_line',
  require 'plugins.neotree',
  require 'plugins.bufferline',
  require 'plugins.toggleterm',
  require 'plugins.trouble',
  require 'plugins.harpoon',
  require 'plugins.outline',
  require 'plugins.markdown_tables',
}

vim.list_extend(plugins, require 'plugins.ui')
vim.list_extend(plugins, require 'plugins.editor')

local opts = {
  rocks = { enabled = false },
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}

return plugins, opts
