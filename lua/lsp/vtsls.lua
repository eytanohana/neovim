-- vtsls LSP: fast TypeScript/JavaScript language server (drop-in tsserver replacement).
-- https://github.com/yioneko/vtsls
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- nvm is lazy-loaded in .zshrc, so Neovim may not see the right node binary.
-- Find the newest node installed via nvm so vtsls always gets a modern runtime.
local function resolve_node()
  local nvm_dir = vim.env.NVM_DIR or (vim.env.HOME .. '/.nvm')
  local versions_dir = nvm_dir .. '/versions/node'
  local handle = vim.uv.fs_scandir(versions_dir)
  if not handle then
    return 'node'
  end
  local latest
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if (typ == 'directory' or typ == 'link') and name:match '^v%d' then
      if not latest or name > latest then
        latest = name
      end
    end
  end
  if latest then
    local bin = versions_dir .. '/' .. latest .. '/bin/node'
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  return 'node'
end

local node = resolve_node()
local vtsls_js = vim.fn.stdpath 'data' .. '/mason/packages/vtsls/node_modules/@vtsls/language-server/bin/vtsls.js'

return {
  cmd = { node, vtsls_js, '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  capabilities = capabilities,
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = { completeFunctionCalls = true },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = { completeFunctionCalls = true },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
  },
}
