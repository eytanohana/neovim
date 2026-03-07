-- BasedPyright LSP: fast type checker and language server for Python.
-- https://docs.basedpyright.com
--
-- Type checking: "standard" for useful diagnostics without being overly strict.
-- Diagnostic mode: "openFilesOnly" — only analyzes open files + their direct
-- imports. Critical for large repos (15k+ files) where "workspace" mode would
-- consume 4–8 GB RAM and peg the CPU for minutes.
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
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'standard',
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          -- Suppress diagnostics that ruff handles (linting, imports, style)
          reportUnusedImport = 'none',
          reportUnusedVariable = 'none',
          reportUnusedClass = 'none',
          reportUnusedFunction = 'none',
          reportUndefinedVariable = 'none', -- ruff F821
          -- Suppress noise from untyped third-party libraries
          reportMissingTypeStubs = 'none',
        },
      },
    },
  },
}
