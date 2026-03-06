-- Highlight, edit, and navigate code. Attach by language name and enable treesitter-based indentation (upstream kickstart pattern).
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
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
  end,
}
