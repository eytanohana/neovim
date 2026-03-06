local clear = { clear = true }

-- create general au group
local general = vim.api.nvim_create_augroup('General', clear)

-- go to the last location the cursor was at when opening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
  group = general,
})

-- check for external edits to the file
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  command = 'checktime',
  group = general,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', clear),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local qflist = vim.api.nvim_create_augroup('QuickFixList', clear)

vim.api.nvim_create_autocmd('FileType', {
  group = qflist,
  pattern = 'qf',
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', 'J', 'j<CR>zz<C-w>j', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'K', 'k<CR>zz<C-w>j', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'q', 'ZQ', { noremap = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('PythonGroup', clear),
  pattern = 'python',
  callback = function()
    vim.opt_local.colorcolumn = '80'
  end,
})
