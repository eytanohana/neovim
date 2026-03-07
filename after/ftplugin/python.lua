-- Python filetype settings.
-- Loaded automatically by Neovim for every Python buffer.

local opt = vim.opt_local

-- PEP 8: 79 chars for code, 72 for docstrings (colorcolumn at 80 as a guide)
opt.colorcolumn = '80'
opt.textwidth = 88 -- ruff/black default line length

-- 4-space indentation (PEP 8)
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Format options: auto-wrap comments, insert comment leader, allow gq on comments
opt.formatoptions = 'croqjnl'

-- Fold imports and long blocks by default but keep everything open on load
opt.foldlevel = 99

-- Copy pytest node ID: path/to/test_file.py::TestClass::test_func
-- Walks treesitter upward from cursor to find the enclosing function and class.
vim.api.nvim_buf_create_user_command(0, 'CopyPytestPath', function()
  local rel = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  local node = vim.treesitter.get_node()
  local parts = {}
  while node do
    if node:type() == 'function_definition' or node:type() == 'class_definition' then
      local name_node = node:field('name')[1]
      if name_node then
        table.insert(parts, 1, vim.treesitter.get_node_text(name_node, 0))
      end
    end
    node = node:parent()
  end
  local result = rel
  if #parts > 0 then
    result = result .. '::' .. table.concat(parts, '::')
  end
  vim.fn.setreg('+', result)
  vim.notify('Copied "' .. result .. '" to clipboard.')
end, { desc = 'Copy pytest node ID for nearest test' })

vim.keymap.set('n', 'cpt', ':CopyPytestPath<CR>', { buffer = 0, silent = true, desc = 'Copy pytest path' })
