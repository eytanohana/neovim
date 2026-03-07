-- Ruff LSP: fast linter and formatter for Python (Rust-based).
-- Used alongside BasedPyright: ruff handles linting/formatting, basedpyright handles types/hover/completion.
-- https://docs.astral.sh/ruff/editors/
local capabilities = require('blink.cmp').get_lsp_capabilities()

return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  capabilities = capabilities,
  on_attach = function(client, _)
    -- Disable hover in favor of basedpyright (avoids duplicate hover popups)
    client.server_capabilities.hoverProvider = false
  end,
}
