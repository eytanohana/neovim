local M = {}

--- Close the current buffer. If it's the last real buffer, exit Neovim.
--- @param opts? { force: boolean } force=true discards unsaved changes
function M.close_buffer(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()

  local other_listed = vim.tbl_filter(function(b)
    return b ~= buf and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())

  local has_sidebar = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == 'neo-tree' or ft == 'undotree' or ft == 'diff' then
      has_sidebar = true
      break
    end
  end

  if #other_listed == 0 and not has_sidebar then
    vim.cmd(opts.force and 'qa!' or 'qa')
    return
  end

  if #other_listed > 0 then
    vim.cmd 'BufferLineCyclePrev'
  else
    vim.cmd 'enew'
  end

  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = opts.force or false })
  end
end

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
