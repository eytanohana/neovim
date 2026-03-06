return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- Run when an LSP attaches to a buffer (e.g. opening main.rs attaches rust_analyzer). See :help lsp-vs-treesitter
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        -- Helper for buffer-local LSP keymaps with a consistent description prefix
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' }) -- cursor on error/suggestion
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration') -- declaration, not definition (e.g. C header)
        map('gs', vim.lsp.buf.signature_help, '[G]et [S]ignature Documentation')

        -- Neovim 0.10 vs 0.11 use different APIs for checking if a client supports a method
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- Highlight references under cursor on CursorHold; clear on CursorMoved
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Toggle inlay hints (can displace code)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    -- Merge in nvim-cmp capabilities so LSPs support completion, signature help, etc.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Server configs: override cmd, filetypes, capabilities, settings per server. See :help lspconfig-all
    local lsp_util = require 'lspconfig.util'
    local servers = {
      -- clangd = {},
      -- gopls = {},
      pyright = {
        -- Find Python project root (git, pyproject.toml, etc.)
        root_dir = function(fname)
          return lsp_util.find_git_ancestor(fname)
            or lsp_util.root_pattern('setup.py', 'pyproject.toml', 'setup.cfg', 'requirements.txt', '.git')(fname)
            or vim.fn.getcwd()
        end,
      },
      rust_analyzer = {},

      -- lua_ls: Neovim runtime in workspace.library so we get vim API completion. We also write
      -- it into .luarc.json in the config dir so lua_ls sees it regardless of client load order.
      lua_ls = (function()
        local runtime = vim.env.VIMRUNTIME
        local runtime_lua = (runtime and runtime ~= '')
            and vim.fn.fnamemodify(runtime .. '/lua', ':p')
          or nil

        -- If config dir .luarc.json doesn't list the Neovim runtime yet, add it once (lua_ls reads it for the workspace)
        if runtime_lua then
          local config_dir = vim.fn.stdpath('config')
          local luarc_path = config_dir .. '/.luarc.json'
          local existing = {}
          local ok, lines = pcall(vim.fn.readfile, luarc_path)
          if ok and lines and #lines > 0 then
            existing = vim.json.decode(table.concat(lines, '\n')) or {}
          end
          local lib = existing.workspace and existing.workspace.library or {}
          if type(lib) ~= 'table' then lib = {} end
          if not vim.tbl_contains(lib, runtime_lua) then
            lib[#lib + 1] = runtime_lua
            existing.workspace = existing.workspace or {}
            existing.workspace.library = lib
            existing.workspace.checkThirdParty = false
            pcall(vim.fn.writefile, vim.split(vim.json.encode(existing), '\n'), luarc_path)
          end
        end

        return {
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
      end)(),
    }

    -- Install LSPs and tools via Mason. Run :Mason to manage.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- format Lua
      'pyright',
      'rust_analyzer',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- mason-lspconfig calls our handler for each server; we merge capabilities and pass server opts from the table above
    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
