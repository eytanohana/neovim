-- Neotest: test runner framework with pytest adapter.
-- Keymaps under <leader>n (registered in which-key as "Neotest").
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },
  keys = {
    {
      '<leader>nr',
      function()
        require('neotest').output_panel.clear()
        require('neotest').run.run()
      end,
      desc = 'Neotest: [R]un nearest test',
    },
    {
      '<leader>nf',
      function()
        require('neotest').output_panel.clear()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Neotest: Run [F]ile',
    },
    {
      '<leader>ns',
      function()
        require('neotest').output_panel.clear()
        require('neotest').run.run { suite = true }
      end,
      desc = 'Neotest: Run [S]uite',
    },
    {
      '<leader>nl',
      function()
        require('neotest').output_panel.clear()
        require('neotest').run.run_last()
      end,
      desc = 'Neotest: Run [L]ast',
    },
    {
      '<leader>no',
      function()
        require('neotest').output.open { enter = true }
      end,
      desc = 'Neotest: Show [O]utput',
    },
    {
      '<leader>np',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Neotest: Toggle output [P]anel',
    },
    {
      '<leader>nm',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Neotest: Toggle su[M]mary',
    },
    {
      '<leader>nd',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = 'Neotest: [D]ebug nearest test',
    },
    {
      '<leader>nS',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Neotest: [S]top running test',
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-python' {
          dap = { justMyCode = false },
          runner = 'pytest',
          -- Use the project-local Python so pytest finds the right venv
          python = function()
            local venv = os.getenv 'VIRTUAL_ENV'
            if venv then
              return venv .. '/bin/python'
            end
            -- Fall back to .venv in the project root
            local cwd = vim.fn.getcwd()
            local local_venv = cwd .. '/.venv/bin/python'
            if vim.fn.executable(local_venv) == 1 then
              return local_venv
            end
            return 'python3'
          end,
          -- Disabled: runs pytest --collect-only which is very slow in large repos.
          -- Tests are still discoverable by function name; only parametrize IDs are lost.
          pytest_discover_instances = false,
        },
      },
      output = { open_on_run = false },
      status = {
        virtual_text = true,
        signs = true,
      },
      quickfix = {
        open = false,
      },
    }
  end,
}
