vim.api.nvim_create_autocmd("VimEnter",
    {
        once = true,
        group = vim.api.nvim_create_namespace("faker"),
        callback = function ()
            require("core.init")
            vim.schedule(function()
                require("lz.n").trigger_load("alpha")
                vim.api.nvim_exec_autocmds("VimEnter", {})
            end)

        end
    })

--TODO: Make a wrapper for vim.schedule and just call alpha's loader b4 requiring core
--require('core.init')
