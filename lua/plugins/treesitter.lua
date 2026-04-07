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
      'json',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'python',
      'yaml', -- optional: render-markdown.nvim frontmatter
    }
    require('nvim-treesitter.install').install(parsers)
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

    -- Textobjects: configure via config.update(), then set keymaps manually
    local ts_config = require 'nvim-treesitter-textobjects.config'
    local ts_select = require 'nvim-treesitter-textobjects.select'
    local ts_move = require 'nvim-treesitter-textobjects.move'

    ts_config.update { select = { lookahead = true } }

    -- Selection textobjects (operator-pending + visual)
    local select_maps = {
      { 'af', '@function.outer', 'Around function' },
      { 'if', '@function.inner', 'Inside function' },
      { 'ac', '@class.outer', 'Around class' },
      { 'ic', '@class.inner', 'Inside class' },
      { 'aa', '@parameter.outer', 'Around argument' },
      { 'ia', '@parameter.inner', 'Inside argument' },
    }
    for _, m in ipairs(select_maps) do
      vim.keymap.set({ 'x', 'o' }, m[1], function()
        ts_select.select_textobject(m[2])
      end, { desc = m[3] })
    end

    -- Movement keymaps (normal + visual + operator-pending)
    local move_maps = {
      { ']m', 'goto_next_start', '@function.outer', 'Next function start' },
      { ']]', 'goto_next_start', '@class.outer', 'Next class start' },
      { ']M', 'goto_next_end', '@function.outer', 'Next function end' },
      { '][', 'goto_next_end', '@class.outer', 'Next class end' },
      { '[m', 'goto_previous_start', '@function.outer', 'Prev function start' },
      { '[[', 'goto_previous_start', '@class.outer', 'Prev class start' },
      { '[M', 'goto_previous_end', '@function.outer', 'Prev function end' },
      { '[]', 'goto_previous_end', '@class.outer', 'Prev class end' },
    }
    for _, m in ipairs(move_maps) do
      vim.keymap.set({ 'n', 'x', 'o' }, m[1], function()
        ts_move[m[2]](m[3])
      end, { desc = m[4] })
    end
  end,
}
