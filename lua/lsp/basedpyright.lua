-- BasedPyright LSP: fast type checker and language server for Python (replaces Pyright).
-- https://docs.basedpyright.com
local capabilities = require('blink.cmp').get_lsp_capabilities()
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyrightconfig.json',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  capabilities = capabilities,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        -- "basic" = fewer diagnostics; use "standard" or "strict" for more. "off" = minimal.
        typeCheckingMode = 'basic',
        -- Do not set useLibraryCodeForTypes here; let pyproject.toml override when unset.
      },
    },
  },
}
