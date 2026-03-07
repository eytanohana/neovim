local map = vim.keymap.set

-- Bootstrap keymaps (moved from init.lua)
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>sl', ':w<CR>:luafile %<CR>', { desc = '[S]ource the current [L]ua file' })

-- Keymaps for better default experience
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map('i', 'jj', '<ESC>')

-- map ; to : and vice versa
map('', ';', ':')
map('', ':', ';')

-- remap ` to switch char case
map('', '`', '~')
map('', '~', '`')

-- map 99 to go to end of line
map('', '99', '$')

-- U to redo
map('n', 'U', '<C-r>')

-- remap 0 to go to beginning of the text on the line
map('n', '0', '^')

-- yank/highlight till the end of line
map('n', 'Y', 'y$')
map('n', 'V', 'v$')

-- highlight entire line
map('n', 'vv', 'V')

-- replace all occurences
map('n', '<C-r>', ':%s//g<Left><Left>')

-- toggle wrap
map('n', 'zx', ':set wrap!<CR>', { desc = 'Toggle text wrapping' })

-- insert line below/above
map('n', 'm', 'o<ESC>')
map('n', 'M', 'O<ESC>')

-- close current buffer (IDE-style: close tab, not Neovim)
map({ 'n', 'v' }, 'ZZ', function()
  if vim.api.nvim_buf_get_name(0) ~= '' then
    vim.cmd 'w'
  end
  require('config.utils').close_buffer()
end, { silent = true, desc = 'Save and close buffer' })

map({ 'n', 'v' }, 'ZX', function()
  require('config.utils').close_buffer { force = true }
end, { silent = true, desc = 'Close buffer without saving' })

-- move lines up/down
map('n', '<C-j>', ':m+<CR>==')
map('n', '<C-k>', ':m-2<CR>==') -- todo: clashes with signature help
map('v', '<C-k>', ":m '<-2<CR>gv=gv")
map('v', '<C-j>', ":m '>+1<CR>gv=gv")
map('i', '<C-k>', '<ESC>:m-2<CR>==')
map('i', '<C-j>', '<ESC>:m+<CR>==')

-- clear the current line
map('n', 'cl', 'S<ESC>', { desc = '[CL]ear the current line' })

-- duplicate current line/selection
map('n', '<leader>p', 'yyp')
map('v', '<leader>p', 'yko<ESC>P}j')

-- Tab works as expected
map('n', '<TAB>', '>>')
map('n', '<S-TAB>', '<<')
map('i', '<S-TAB>', '<C-d>')
map('v', '<TAB>', '>gv')
map('v', '<S-TAB>', '<gv')

-- copy paths of current buffer
map('n', 'cp', ':CopyAbsFilePath<CR>', { silent = true, desc = 'Copy absolute file path' })
map('n', 'cd', ':CopyAbsDirPath<CR>', { silent = true, desc = 'Copy absolute dir path' })
map('n', 'crp', ':CopyRelFilePath<CR>', { silent = true, desc = 'Copy relative file path' })
map('n', 'crd', ':CopyRelDirPath<CR>', { silent = true, desc = 'Copy relative dir path' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic navigation
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
map('n', ']e', function()
  vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Next error' })
map('n', '[e', function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Prev error' })

-- Quickfix / location list navigation
map('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix entry' })
map('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Prev quickfix entry' })
map('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next loclist entry' })
map('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Prev loclist entry' })

-- Centered scrolling — keeps cursor in the middle of the screen when jumping
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })

-- Stable cursor on line join
map('n', 'J', 'mzJ`z')

-- Toggle relative line numbers (under [T]oggle to avoid conflict with LSP rename on <leader>rn)
map('n', '<leader>tn', ':set relativenumber!<CR>', { desc = '[T]oggle relative line [N]umbers' })

-- Toggle diagnostics virtual text
map('n', '<leader>td', function()
  local cfg = vim.diagnostic.config()
  if cfg.virtual_text then
    vim.diagnostic.config { virtual_text = false }
    vim.notify('Diagnostics virtual text OFF', vim.log.levels.INFO)
  else
    vim.diagnostic.config { virtual_text = { source = 'if_many', spacing = 2 } }
    vim.notify('Diagnostics virtual text ON', vim.log.levels.INFO)
  end
end, { desc = '[T]oggle [D]iagnostics virtual text' })

-- split navigations (M is Alt)
map('n', '<A-j>', '<C-W>j')
map('n', '<A-k>', '<C-W>k')
map('n', '<A-h>', '<C-W>h')
map('n', '<A-l>', '<C-W>l')
map('i', '<A-j>', '<esc><C-W>j')
map('i', '<A-k>', '<esc><C-W>k')
map('i', '<A-h>', '<esc><C-W>h')
map('i', '<A-l>', '<esc><C-W>l')

-- adjust split sizes more user friendly
map('n', '<C-A-S-H>', ':vertical resize +3<CR>')
map('n', '<C-A-S-L>', ':vertical resize -3<CR>')
map('n', '<C-A-S-K>', ':resize +3<CR>')
map('n', '<C-A-S-J>', ':resize -3<CR>')

-- buffer tab navigation (bufferline)
map('n', '<A-i>', '<cmd>BufferLineCyclePrev<CR>', { silent = true, desc = 'Previous buffer tab' })
map('n', '<A-o>', '<cmd>BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer tab' })
map('n', '<A-S-I>', '<cmd>BufferLineMovePrev<CR>', { silent = true, desc = 'Move buffer tab left' })
map('n', '<A-S-O>', '<cmd>BufferLineMoveNext<CR>', { silent = true, desc = 'Move buffer tab right' })

-- reformat jsons
map('n', '\\j', ':%!python -m json.tool<CR>')

-- dont copy pasted over text
map('v', 'p', '"_dP')

-- exit v mode with nn
map('v', 'nn', '<ESC>')

--- ppp to paste in insert mode
map('i', 'ppp', '<ESC>p')

-- select/yank all
map('n', 'vaa', 'ggVG')
map('n', 'yaa', 'ggVGy')

map('n', '<A-S-H>', '<C-o>')
map('n', '<A-S-L>', '<C-i>')

-- Close gitsigns blame from inside the blame buffer (where on_attach doesn't fire).
map('n', '<leader>gb', function()
  require('config.utils').close_blame()
end)
