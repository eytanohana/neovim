-- Two-space JSON is the usual convention; Conform's jq formatter uses 'shiftwidth'.
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

-- Folds: global foldexpr uses treesitter (see lua/config/options.lua). They only apply once
-- the file has structure (run <leader>f or \j on a minified one-liner first). Then zM / zR / zo / zc.
