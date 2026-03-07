-- debug.lua
--
-- DAP (debug adapter protocol) for debugging code. Primarily Go/Python/Rust.

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      { '<F9>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<leader>rt', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F7>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F8>', dap.step_over, desc = 'Debug: Step Over' },
      { '<S-F7>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      { '<F6>', dapui.toggle, desc = 'Debug: Toggle DAP UI' },
      { '<leader>du', dapui.toggle, desc = '[D]ebug: Toggle DAP [U]I' },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve', 'codelldb', 'python' },
    }

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          play = '▶',
          pause = '⏸',
          terminate = '⏹',
          step_into = '',
          step_over = '',
          step_out = '',
          step_back = '',
          run_last = '',
          disconnect = '',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          position = 'right',
          size = 40,
        },
        {
          elements = { { id = 'repl', size = 0.5 }, { id = 'console', size = 0.5 } },
          position = 'bottom',
          size = 10,
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open

    dap.configurations.rust = {
      {
        name = 'Launch Rust Executable',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local cwd = vim.fn.getcwd()
          local projectName = vim.fn.fnamemodify(cwd, ':t')
          local build_output = vim.fn.system 'cargo build'
          if vim.v.shell_error ~= 0 then
            print('Build failed:\n' .. build_output)
            return nil
          else
            print 'Build succeeded!'
          end
          local default_exec = cwd .. '/target/debug/' .. projectName
          return vim.fn.input('Path to executable: ', default_exec, 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- Resolve debugpy Python: prefer Mason-managed install, fall back to legacy location.
    -- Mason installs debugpy under its packages directory with its own venv.
    local mason_debugpy = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
    local legacy_debugpy = vim.fn.stdpath 'data' .. '/debugpy/bin/python'
    local debugpy_python = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or legacy_debugpy
    require('dap-python').setup(debugpy_python)
    require('dap-python').test_runner = 'pytest'
    require('dap-go').setup {
      delve = { detached = vim.fn.has 'win32' == 0 },
    }
  end,
}
