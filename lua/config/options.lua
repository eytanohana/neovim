local set = vim.opt

-- set tabs to 4 spaces
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4

-- show tabs
set.showtabline = 2

-- be smart when using tabs ;)
set.smarttab = true
set.smartindent = true

-- expand tabs into spaces
set.expandtab = true

-- auto indent
set.autoindent = true

-- Show which line your cursor is on
set.cursorline = true

-- show line numbers/relative line numbers
set.number = true
set.relativenumber = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
set.ignorecase = true
set.smartcase = true

-- disable swap file
set.swapfile = false

-- file formats/encodings
set.fileformat = 'unix'
set.encoding = 'utf-8'

-- Set to auto read when a file is changed from the outside
set.autoread = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  set.clipboard = 'unnamedplus'
end)

-- keep the cursor 2 lines from the top/bottom
set.scrolloff = 2

-- open new splits below and right
set.splitbelow = true
set.splitright = true

-- Enable folding
set.foldmethod = 'indent'
set.foldlevel = 99

-- dont autowrap long lines
set.wrap = false

-- Don't redraw while executing macros (good performance config)
set.lazyredraw = true

-- For regular expressions turn magic on
set.magic = true

-- visual block stays in its lane
set.startofline = false

-- better menu completion/selection
set.completeopt = 'menuone,noinsert,noselect'

-- set undotree file directory
set.undodir = os.getenv 'HOME' .. '/.config/nvim/.undodir'
set.undofile = true

-- Enable mouse mode, can be useful for resizing splits for example!
set.mouse = 'a'

-- highlight search
set.hlsearch = true

-- Decrease update time (ms)
set.updatetime = 250
set.timeoutlen = 300

set.signcolumn = 'auto'

-- more terminal colors
set.termguicolors = true

-- Enable break indent
set.breakindent = true

-- Don't show the mode, since it's already in the status line
set.showmode = false

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- set.list = true
-- set.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- set.listchars = { tab = '▎', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
set.inccommand = 'split'
