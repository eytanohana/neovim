-- Pyright LSP config for Neovim 0.11+ native vim.lsp.config.
local capabilities = require('blink.cmp').get_lsp_capabilities()
return {
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  capabilities = capabilities,
}
