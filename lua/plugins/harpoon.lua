return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local map = vim.keymap.set
    map('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon: add file' })
    map('n', '<leader>e', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: toggle menu' })

    for i = 1, 5 do
      map('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Harpoon: go to file ' .. i })
    end
  end,
}
