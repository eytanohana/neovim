vim.api.nvim_create_user_command('CP',
    function()
        local path = vim.api.nvim_buf_get_name(0)
        path = path:match('(.*[/\\])')
        vim.fn.setreg("+", path)
        vim.notify('Copied "' .. path .. '" to clipboard.')
    end, {})
