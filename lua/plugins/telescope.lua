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
    { 'nvim-telescope/telescope-frecency.nvim', version = '*' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    --- Prefer the main editor split when the picker was opened from ToggleTerm (or any terminal),
    --- so files open in bufferline instead of replacing the terminal buffer.
    local function pick_largest_normal_window()
      local best_win, best_area = nil, 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bo = vim.bo[buf]
        if bo.buftype == '' and bo.filetype ~= 'toggleterm' then
          local area = vim.api.nvim_win_get_width(win) * vim.api.nvim_win_get_height(win)
          if area > best_area then
            best_area, best_win = area, win
          end
        end
      end
      return best_win
    end

    require('telescope').setup {
      defaults = {
        get_selection_window = function(picker, _entry)
          local orig = picker.original_win_id
          if vim.api.nvim_win_is_valid(orig) then
            local buf = vim.api.nvim_win_get_buf(orig)
            local bo = vim.bo[buf]
            if bo.buftype == '' and bo.filetype ~= 'toggleterm' then
              return 0
            end
          end
          return pick_largest_normal_window() or 0
        end,
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
    pcall(require('telescope').load_extension, 'frecency')

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
    vim.keymap.set('n', '<leader>sd', function()
      builtin.diagnostics { bufnr = 0 }
    end, { desc = '[S]earch [D]iagnostics (buffer)' })
    vim.keymap.set('n', '<leader>sD', builtin.diagnostics, { desc = '[S]earch [D]iagnostics (workspace)' })
    vim.keymap.set('n', '<leader>sr', '<cmd>Telescope frecency workspace=CWD<cr>', { desc = '[S]earch [R]ecent Files (frecency, cwd only)' })
    vim.keymap.set('n', '<leader>s.', builtin.resume, { desc = '[S]earch Resume (reopen last picker)' })
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

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>sT', function()
      builtin.live_grep {
        prompt_title = 'Grep in Tests',
        glob_pattern = { 'test_*.py', '*_test.py', 'tests/**/*.py', 'test/**/*.py' },
      }
    end, { desc = '[S]earch in [T]ests (Python)' })

    vim.keymap.set('n', '<leader>sP', function()
      builtin.live_grep {
        prompt_title = 'Grep in Python Source',
        type_filter = 'py',
        glob_pattern = { '!test_*.py', '!*_test.py', '!tests/**', '!test/**', '!conftest.py' },
      }
    end, { desc = '[S]earch in [P]ython source (no tests)' })
  end,
}
