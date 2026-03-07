return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        dynamic_preview_title = true,
        path_display = { 'smart' },
        file_ignore_patterns = {
          '%.pyc$',
          '__pycache__/',
          '%.mypy_cache/',
          '%.pytest_cache/',
          '%.ruff_cache/',
          '%.venv/',
          'venv/',
          '%.tox/',
          '%.nox/',
          '%.eggs/',
          '%.egg%-info/',
          'dist/',
          'build/',
          'node_modules/',
          '%.git/',
        },
        mappings = {
          i = {
            ['<c-enter>'] = 'to_fuzzy_refine',
            ['<C-j>'] = {
              require('telescope.actions').move_selection_next,
              type = 'action',
              opts = { nowait = true, silent = true },
            },
            ['<C-k>'] = {
              require('telescope.actions').move_selection_previous,
              type = 'action',
              opts = { nowait = true, silent = true },
            },
          },
        },
      },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>ss', builtin.find_files, { desc = '[S]earch File[S]' })
    vim.keymap.set('n', '<leader>st', builtin.git_files, { desc = '[S]earch Gi[T] Files' })
    vim.keymap.set('n', '<leader>sb', builtin.builtin, { desc = '[S]earch Telescope [B]uiltins' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

    vim.keymap.set('n', '<C-S-F>', function()
      -- Get the copied text
      local text = vim.fn.getreg '"'
      require('telescope.builtin').grep_string { search = text }
    end, { desc = 'Search for yanked selection' })

    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.oldfiles, { desc = '[S]earch [R]ecent Files' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '?', builtin.current_buffer_fuzzy_find, { desc = '[?] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>/', function()
      local word = vim.fn.input '/'
      if word == '' then
        return
      end
      require('telescope.builtin').grep_string {
        search = word,
        use_regex = true,
        search_dirs = { vim.fn.expand '%:p' },
      }
      if word and word ~= '' then
        vim.fn.setreg('/', word)
        vim.opt.hlsearch = true
      end
    end, { desc = 'Grep current buffer via Telescope' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Python workflow: grep only in test files
    vim.keymap.set('n', '<leader>sT', function()
      builtin.live_grep {
        prompt_title = 'Grep in Tests',
        glob_pattern = { 'test_*.py', '*_test.py', 'tests/**/*.py', 'test/**/*.py' },
      }
    end, { desc = '[S]earch in [T]ests (Python)' })

    -- Python workflow: grep in source, excluding test files
    vim.keymap.set('n', '<leader>sP', function()
      builtin.live_grep {
        prompt_title = 'Grep in Python Source',
        type_filter = 'py',
        glob_pattern = { '!test_*.py', '!*_test.py', '!tests/**', '!test/**', '!conftest.py' },
      }
    end, { desc = '[S]earch in [P]ython source (no tests)' })
  end,
}
