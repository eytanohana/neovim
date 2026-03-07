-- Floating :LspInfo window for Neovim 0.11+ native LSP.
-- Shows attached clients, their config, and all other active clients.

local M = {}

local function client_status(client)
  if client.is_stopped and client:is_stopped() then
    return 'stopped'
  end
  if client.initialized then
    return 'running'
  end
  return 'starting'
end

local function format_cmd(client)
  local cfg = client.config or {}
  if cfg.cmd and type(cfg.cmd) == 'table' then
    return table.concat(cfg.cmd, ' ')
  end
  return tostring(cfg.cmd or '?')
end

local function buf_label(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return string.format('[%d] (unnamed)', bufnr)
  end
  return string.format('[%d] %s', bufnr, vim.fn.fnamemodify(name, ':~:.'))
end

local function append(lines, hl, text, group)
  lines[#lines + 1] = text
  if group then
    hl[#hl + 1] = { #lines - 1, group }
  end
end

local function add_client_block(lines, hl, client)
  local status = client_status(client)
  local status_icon = status == 'running' and '●' or status == 'starting' and '○' or '✕'
  local status_hl = status == 'running' and 'DiagnosticOk' or status == 'starting' and 'DiagnosticWarn' or 'DiagnosticError'

  append(lines, hl, string.format('  %s %s (id: %d)', status_icon, client.name, client.id), status_hl)
  append(lines, hl, string.format('    cmd:       %s', format_cmd(client)))

  local root = client.root_dir or (client.config and client.config.root_dir)
  if root then
    append(lines, hl, string.format('    root:      %s', vim.fn.fnamemodify(root, ':~')))
  end

  local ft = client.config and client.config.filetypes
  if ft and #ft > 0 then
    append(lines, hl, string.format('    filetypes: %s', table.concat(ft, ', ')))
  end

  local attached = vim.lsp.get_buffers_by_client_id(client.id) or {}
  if #attached > 0 then
    local labels = {}
    for _, b in ipairs(attached) do
      labels[#labels + 1] = buf_label(b)
    end
    append(lines, hl, string.format('    buffers:   %s', table.concat(labels, ', ')))
  end

  append(lines, hl, '')
end

function M.open()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':~:.')
  if bufname == '' then
    bufname = '(unnamed)'
  end

  local lines = {}
  local hl = {} -- { line_0idx, hl_group }

  append(lines, hl, '  Buffer:   ' .. bufname)
  append(lines, hl, '  Filetype: ' .. (ft ~= '' and ft or '(none)'))
  append(lines, hl, '')

  -- Clients attached to the current buffer
  local attached = vim.lsp.get_clients { bufnr = bufnr }
  append(lines, hl, '  Attached clients (' .. #attached .. ')', 'Title')
  append(lines, hl, '')

  if #attached == 0 then
    append(lines, hl, '  (none)', 'Comment')
    append(lines, hl, '')
  else
    for _, client in ipairs(attached) do
      add_client_block(lines, hl, client)
    end
  end

  -- Other active clients not attached to this buffer
  local all = vim.lsp.get_clients()
  local attached_ids = {}
  for _, c in ipairs(attached) do
    attached_ids[c.id] = true
  end
  local others = vim.tbl_filter(function(c)
    return not attached_ids[c.id]
  end, all)

  if #others > 0 then
    append(lines, hl, '  Other active clients (' .. #others .. ')', 'Title')
    append(lines, hl, '')
    for _, client in ipairs(others) do
      add_client_block(lines, hl, client)
    end
  end

  append(lines, hl, '  Log: ' .. vim.lsp.get_log_path(), 'Comment')
  append(lines, hl, '')
  append(lines, hl, '  Press q or <Esc> to close', 'Comment')

  -- Create floating window
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 4, math.floor(vim.o.columns * 0.85))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.75))

  local float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = 'wipe'
  vim.bo[float_buf].filetype = 'lspinfo'

  local win = vim.api.nvim_open_win(float_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' LSP Info ',
    title_pos = 'center',
  })

  -- Apply highlights
  for _, h in ipairs(hl) do
    local line_idx, group = h[1], h[2]
    if line_idx < #lines then
      vim.api.nvim_buf_add_highlight(float_buf, -1, group, line_idx, 0, -1)
    end
  end

  -- Close keymaps
  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set('n', 'q', close, { buffer = float_buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = float_buf, nowait = true })
end

return M
