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

vim.api.nvim_create_autocmd('BufLeave', {
  group = general,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    local is_modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
    local readable = vim.fn.filereadable(filename) == 1
    local writable = vim.fn.filewritable(filename) == 1

    -- Save the buffer if it's a real file, not related to plugins, and is modified
    if readable and writable and is_modified then
      vim.cmd 'write'
    end
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', clear),
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

local python_group = vim.api.nvim_create_augroup('PythonGroup', clear)
vim.api.nvim_create_autocmd('FileType', {
  group = python_group,
  pattern = 'python',
  callback = function()
    vim.cmd [[ CC ]]
  end,
})
