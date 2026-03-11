local map = vim.keymap.set
local group = vim.api.nvim_create_augroup('toggle_term', { clear = true })

local state = {
  last_focused_term_id = 1,
}

local function stop_insert_if_needed()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'i' or mode == 'ic' or mode == 't' then
    vim.cmd 'stopinsert'
  end
end

local function is_toggleterm_buf(buf)
  return vim.bo[buf].filetype == 'toggleterm'
end

local function get_buf_term_id(buf)
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, 'toggle_number')
  if ok then
    return tonumber(value)
  end
  return nil
end

local function get_toggleterm_wins()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_toggleterm_buf(buf) then
      table.insert(wins, win)
    end
  end
  return wins
end

local function current_win_is_toggleterm()
  return is_toggleterm_buf(vim.api.nvim_get_current_buf())
end

local function find_win_for_term_id(term_id)
  for _, win in ipairs(get_toggleterm_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if get_buf_term_id(buf) == term_id then
      return win
    end
  end
  return nil
end

local function focus_last_focused_term()
  local win = find_win_for_term_id(state.last_focused_term_id)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    vim.cmd 'startinsert'
    return true
  end

  local wins = get_toggleterm_wins()
  if #wins > 0 then
    vim.api.nvim_set_current_win(wins[1])
    vim.cmd 'startinsert'
    return true
  end

  return false
end

local function next_terminal_id()
  local max_id = 0

  for _, win in ipairs(get_toggleterm_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local term_id = get_buf_term_id(buf)
    if term_id and term_id > max_id then
      max_id = term_id
    end
  end

  -- also check existing hidden terminals if available
  local ok, terminals = pcall(function()
    return require('toggleterm.terminal').get_all()
  end)

  if ok and terminals then
    for _, term in ipairs(terminals) do
      local id = term.id or term.count
      if id and id > max_id then
        max_id = id
      end
    end
  end

  return max_id + 1
end

local function toggle_or_focus_bottom_terms()
  stop_insert_if_needed()

  local term_wins = get_toggleterm_wins()

  if #term_wins == 0 then
    vim.cmd 'ToggleTerm direction=horizontal'
    return
  end

  if current_win_is_toggleterm() then
    vim.cmd 'ToggleTerm'
    return
  end

  focus_last_focused_term()
end

local function open_new_terminal_right()
  stop_insert_if_needed()

  local term_wins = get_toggleterm_wins()

  if #term_wins == 0 then
    vim.cmd 'ToggleTerm direction=horizontal'
    return
  end

  if not current_win_is_toggleterm() then
    focus_last_focused_term()
    stop_insert_if_needed()
  end

  local id = next_terminal_id()
  vim.cmd(('%dToggleTerm direction=horizontal'):format(id))
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'TermEnter' }, {
  group = group,
  callback = function(ev)
    if not is_toggleterm_buf(ev.buf) then
      return
    end
    local term_id = get_buf_term_id(ev.buf)
    if term_id then
      state.last_focused_term_id = term_id
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'toggleterm',
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    map('t', '<A-2>', toggle_or_focus_bottom_terms, opts)
    map('t', '<A-3>', open_new_terminal_right, opts)

    map({ 't', 'n' }, '<A-x>', function()
      local buf = vim.api.nvim_get_current_buf()
      local term_id = get_buf_term_id(buf)
      if term_id then
        require('toggleterm.terminal').get(term_id):shutdown()
      end
    end, opts)

    map('t', '<A-h>', [[<Cmd>wincmd h<CR>]], opts)
    map('t', '<A-j>', [[<Cmd>wincmd j<CR>]], opts)
    map('t', '<A-k>', [[<Cmd>wincmd k<CR>]], opts)
    map('t', '<A-l>', [[<Cmd>wincmd l<CR>]], opts)
  end,
})

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      direction = 'horizontal',
      size = 20,
      persist_mode = true,
      persist_size = true,
      start_in_insert = false,
      close_on_exit = false,
    }

    map({ 'n', 'i' }, '<A-2>', toggle_or_focus_bottom_terms, { silent = true })
    map({ 'n', 'i' }, '<A-3>', open_new_terminal_right, { silent = true })

    local trim_spaces = true
    map('n', '<leader>rt', function()
      require('toggleterm').send_lines_to_terminal('single_line', trim_spaces, { args = vim.v.count })
    end, { desc = '[R]un in [T]erminal' })

    map('v', '<leader>rt', function()
      require('toggleterm').send_lines_to_terminal('visual_selection', trim_spaces, { args = vim.v.count })
    end, { desc = '[R]un in [T]erminal' })
  end,
}
