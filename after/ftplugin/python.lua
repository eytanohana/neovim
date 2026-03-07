-- Python filetype settings.
-- Loaded automatically by Neovim for every Python buffer.

local opt = vim.opt_local

-- PEP 8: 79 chars for code, 72 for docstrings (colorcolumn at 80 as a guide)
opt.colorcolumn = '80'
opt.textwidth = 88 -- ruff/black default line length

-- 4-space indentation (PEP 8)
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Format options: auto-wrap comments, insert comment leader, allow gq on comments
opt.formatoptions = 'croqjnl'

-- Fold imports and long blocks by default but keep everything open on load
opt.foldlevel = 99
