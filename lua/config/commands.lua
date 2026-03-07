vim.api.nvim_create_user_command('LspInfo', function()
  require('lsp.info').open()
end, { desc = 'Show active LSP clients in a floating window' })

vim.api.nvim_create_user_command('CopyAbsDirPath', function()
  local path = vim.api.nvim_buf_get_name(0)
  path = path:match '(.*[/\\])'
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard.')
end, {})

vim.api.nvim_create_user_command('CopyAbsFilePath', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard.')
end, {})

vim.api.nvim_create_user_command('CopyRelFilePath', function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard.')
end, {})

vim.api.nvim_create_user_command('CopyRelDirPath', function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.:h')
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard.')
end, {})
