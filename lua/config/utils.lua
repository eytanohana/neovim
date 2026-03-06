local M = {}

--- Wipe all gitsigns blame buffers. Returns true if any were found.
function M.close_blame()
  local found = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):find('gitsigns-blame', 1, true) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
      found = true
    end
  end
  return found
end

return M
