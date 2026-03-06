local map = vim.keymap.set
local toggle_term_group = vim.api.nvim_create_augroup('toggle_term', { clear = true })

local function toggle_or_focus_toggleterm()
  if vim.fn.mode() == 'i' then
    vim.cmd 'stopinsert'
  end
  local term_winid = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, 'filetype') == 'toggleterm' then
      term_winid = win
      break
    end
  end
  if term_winid then
    if vim.api.nvim_get_current_win() == term_winid then
      vim.cmd 'ToggleTerm'
    else
      vim.api.nvim_set_current_win(term_winid)
    end
  else
    vim.cmd 'ToggleTerm direction=horizontal'
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = toggle_term_group,
  pattern = 'toggleterm',
  callback = function()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(0, 't', '<A-3>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<A-h>', [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<A-j>', [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<A-k>', [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<A-l>', [[<C-\><C-n><C-W>l]], opts)
  end,
})

map({ 'n', 'i' }, '<A-3>', toggle_or_focus_toggleterm)

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      direction = 'horizontal',
      size = 20,
    }
  end,
}
