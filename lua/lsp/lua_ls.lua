-- lua_ls LSP config for Neovim 0.11+ native vim.lsp.config.
-- lazydev.nvim injects Neovim API into workspace; .luarc.json can also list runtime library.
local capabilities = require('blink.cmp').get_lsp_capabilities()
local runtime = vim.env.VIMRUNTIME
local runtime_lua = (runtime and runtime ~= '') and vim.fn.fnamemodify(runtime .. '/lua', ':p') or nil
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      diagnostics = { disable = { 'missing-fields' } },
      workspace = {
        library = runtime_lua and { runtime_lua } or {},
        checkThirdParty = false,
      },
    },
  },
}
