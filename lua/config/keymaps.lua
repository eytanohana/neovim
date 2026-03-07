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

-- save and quit in visual mode
map('v', 'ZZ', '<ESC>ZZ')

-- just quit
map({ 'n', 'v' }, 'ZX', '<ESC>ZQ')

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

-- copy absoulute path of current buffer
map('n', 'cp', ':let @+ = expand("%:p")<CR>:echo @+<CR>')

-- copy absoulute directory path of current buffer
map('n', 'cd', ':CopyAbsDirPath<CR>', { silent = true }) -- todo: add CP

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Toggle relative line numbers. In LSP buffers, <leader>rn is buffer-local LSP rename; this global binding applies elsewhere.
map('n', '<leader>rn', ':set relativenumber!<CR>')

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

map('n', '<A-i>', 'gT')
map('n', '<A-o>', 'gt')

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

map('n', '<A-S-I>', ':tabmove -1<CR>', { silent = true })
map('n', '<A-S-O>', ':tabmove +1<CR>', { silent = true })

-- Close gitsigns blame from inside the blame buffer (where on_attach doesn't fire).
map('n', '<leader>gb', function()
  require('config.utils').close_blame()
end)
