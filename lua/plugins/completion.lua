-- Autocompletion via blink.cmp (performant, batteries-included; replaces nvim-cmp).
-- Blink provides LSP capabilities internally; see lsp.lua for get_lsp_capabilities().
return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = { 'rafamadriz/friendly-snippets' },
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },
  },
  opts = {
    keymap = {
      preset = 'default',
      -- Restore previous nvim-cmp–style keymaps (adapted for blink)
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      -- Tab: accept selected item when not in a snippet; jump forward in snippet otherwise
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return
          end
          return cmp.select_and_accept()
        end,
        'snippet_forward',
        'fallback',
      },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },
    appearance = {
      nerd_font_variant = vim.g.have_nerd_font and 'mono' or 'normal',
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    signature = { enabled = true },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
