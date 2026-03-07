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
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', 'J', 'j<CR>zz<C-w>j', opts)
    vim.keymap.set('n', 'K', 'k<CR>zz<C-w>j', opts)
    vim.keymap.set('n', 'q', 'ZQ', opts)
  end,
})

-- Python-specific settings live in after/ftplugin/python.lua

-- Large file guard: disable expensive features for files > 1 MB or 10k lines.
-- Prevents treesitter, LSP, indent guides, and folds from freezing the editor
-- on generated files, large fixtures, or minified code.
local largefile = vim.api.nvim_create_augroup('LargeFile', clear)
local largefile_threshold = 1024 * 1024 -- 1 MB

vim.api.nvim_create_autocmd('BufReadPre', {
  group = largefile,
  callback = function(ev)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if not ok or not stats then
      return
    end
    if stats.size > largefile_threshold then
      vim.b[ev.buf].largefile = true
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = largefile,
  callback = function(ev)
    if not vim.b[ev.buf].largefile and vim.api.nvim_buf_line_count(ev.buf) <= 10000 then
      return
    end
    vim.b[ev.buf].largefile = true
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldexpr = '0'
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end
      pcall(vim.treesitter.stop, ev.buf)
      -- Detach LSP clients from this buffer
      for _, client in ipairs(vim.lsp.get_clients { bufnr = ev.buf }) do
        vim.lsp.buf_detach_client(ev.buf, client.id)
      end
      -- Disable indent-blankline for this buffer
      local ibl_ok, ibl = pcall(require, 'ibl')
      if ibl_ok then
        ibl.setup_buffer(ev.buf, { enabled = false })
      end
      vim.notify('Large file detected — treesitter, LSP, and indent guides disabled', vim.log.levels.WARN)
    end)
  end,
})
