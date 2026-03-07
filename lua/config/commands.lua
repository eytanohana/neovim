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
