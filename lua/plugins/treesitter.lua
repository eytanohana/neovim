-- Highlight, edit, and navigate code. Attach by language name and enable treesitter-based indentation (upstream kickstart pattern).
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      lazy = true,
    },
  },
  config = function()
    local parsers = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'python',
    }
    require('nvim-treesitter.install').ensure_installed(parsers)
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end
        if not vim.treesitter.language.add(language) then
          return
        end
        vim.treesitter.start(buf, language)
        -- Treesitter-based indentation. Disable for languages where it's problematic.
        local ts_indent_blacklist = { ruby = true, python = true, lua = true }
        if not ts_indent_blacklist[language] then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- Textobjects: function/class selection and movement (works across all TS languages)
    local ts_select = require 'nvim-treesitter-textobjects.select'
    local ts_move = require 'nvim-treesitter-textobjects.move'

    ts_select.setup {
      lookahead = true,
      keymaps = {
        ['af'] = { query = '@function.outer', desc = 'Around function' },
        ['if'] = { query = '@function.inner', desc = 'Inside function' },
        ['ac'] = { query = '@class.outer', desc = 'Around class' },
        ['ic'] = { query = '@class.inner', desc = 'Inside class' },
        ['aa'] = { query = '@parameter.outer', desc = 'Around argument' },
        ['ia'] = { query = '@parameter.inner', desc = 'Inside argument' },
      },
    }

    ts_move.setup {
      goto_next_start = {
        [']m'] = { query = '@function.outer', desc = 'Next function start' },
        [']]'] = { query = '@class.outer', desc = 'Next class start' },
      },
      goto_next_end = {
        [']M'] = { query = '@function.outer', desc = 'Next function end' },
        [']['] = { query = '@class.outer', desc = 'Next class end' },
      },
      goto_previous_start = {
        ['[m'] = { query = '@function.outer', desc = 'Prev function start' },
        ['[['] = { query = '@class.outer', desc = 'Prev class start' },
      },
      goto_previous_end = {
        ['[M'] = { query = '@function.outer', desc = 'Prev function end' },
        ['[]'] = { query = '@class.outer', desc = 'Prev class end' },
      },
    }

    -- Make textobject movements repeatable with ; and , (like built-in f/t)
    local ts_repeat = require 'nvim-treesitter-textobjects.repeatable_move'
    vim.keymap.set({ 'n', 'x', 'o' }, '<A-.>', ts_repeat.repeat_last_move_next)
    vim.keymap.set({ 'n', 'x', 'o' }, '<A-,>', ts_repeat.repeat_last_move_previous)
  end,
}
