-- BasedPyright LSP: fast type checker and language server for Python.
-- https://docs.basedpyright.com
--
-- Type checking set to "standard" for useful diagnostics without being overly strict.
-- Per-project override: add pyrightconfig.json or [tool.basedpyright] in pyproject.toml.
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
      disableOrganizeImports = true, -- ruff handles import sorting
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'standard',
        -- Auto-detect .venv, venv, etc. in the project root
        autoImportCompletions = true,
      },
    },
  },
}
