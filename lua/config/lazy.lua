local ui_plugins = require 'plugins.ui'
local editor_plugins = require 'plugins.editor'
local plugins = {
  -- Load lazydev before any Lua buffer is read so lua_ls gets the Neovim API
  -- as soon as it starts (fixes first-opened Lua file only getting text completion).
  {
    'folke/lazydev.nvim',
    event = { 'BufReadPre' },
    pattern = { '*.lua' },
    priority = 10000,
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  editor_plugins[1],
  editor_plugins[2],
  require 'plugins.git',
  require 'plugins.telescope',
  require 'plugins.completion', -- before lsp so blink.cmp is loaded and get_lsp_capabilities() is available
  require 'plugins.lsp',

  require 'plugins.formatting',

  ui_plugins[1],
  ui_plugins[2],
  ui_plugins[3],
  ui_plugins[4],

  require 'plugins.treesitter',

  require 'plugins.debug',
  require 'plugins.indent_line',
  require 'plugins.autopairs',
  require 'plugins.neotree',
  require 'plugins.toggleterm',

  -- Plugins from lua/custom/plugins/*.lua (add your own there). See :help lazy.nvim-structuring-your-plugins
  { import = 'custom.plugins' },
}

local opts = {
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
