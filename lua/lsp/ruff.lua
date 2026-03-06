-- Ruff LSP: fast linter and formatter for Python (Rust-based). Use with BasedPyright for types/completion.
-- https://docs.astral.sh/ruff/editors/
-- Omit init_options so Ruff uses defaults and picks up pyproject.toml / ruff.toml (avoids "invalid client settings").
local capabilities = require('blink.cmp').get_lsp_capabilities()
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  capabilities = capabilities,
}
