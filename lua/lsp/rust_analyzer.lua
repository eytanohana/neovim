-- rust_analyzer LSP config for Neovim 0.11+ native vim.lsp.config.
local capabilities = require('blink.cmp').get_lsp_capabilities()
return {
  capabilities = capabilities,
}
