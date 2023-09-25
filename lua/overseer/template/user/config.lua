local overseer = require("overseer")

return {
    condition = {
        dir = "/home/strange_cofunctor",
    },
    generator = function(_, cb)
        cb({
            {
                name = "Source File",
                builder = function()
                    vim.cmd.source(vim.fn.expand("%"))
                    return {
                        cmd = "",
                        name = "",
                        components = { "user.dispose_now" },
                    }
                end,
                priority = 59,
                params = {},
                conditions = { filetype = "lua" },
            },
            {
                name = "Build and Reload XMonad",
                builder = function()
                    return {
                        name = "Reload XMonad",
                        cwd = "/home/strange_cofunctor/.xmonad",
                        cmd = "/home/strange_cofunctor/.xmonad/build",
                        components = { "default", "unique" },
                    }
                end,
                priority = 60,
                tags = { overseer.TAG.BUILD },
                params = {},
            },
            {
                name = "Reload Kitty",
                builder = function()
                    return {
                        name = "Reload Kitty",
                        cmd = "pkill -10 kitty",
                        components = { "default", "unique" },
                    }
                end,
                priority = 60,
                params = {},
            },
            {
                name = "View xsession Logs",
                builder = function()
                    return {
                        name = "View xsession Logs",
                        cmd = "tail --follow --retry ~/.xsession-errors | less -S",
                        components = {
                            "default",
                            "unique",
                            {
                                "user.start_open",
                                goto_prev = true,
                            },
                        },
                    }
                end,
                priority = 60,
                params = {},
            },
        })
    end,
}
