local files = require("overseer.files")

local isInProject = function(opts)
    return files.exists(files.join(opts.dir, "meson.build")) or files.exists(files.join(opts.dir), "Cmakelist.txt")
end

return {
    condition = {
        callback = function(opts)
            return vim.bo.filetype=="nix" or isInProject(opts)
        end
    },
    generator = function(_, cb)
        local ret = {}
        local priority = 60
        local pr = function()
            priority = priority + 1
            return priority
        end

        --Generic tasks go here
        local generic_cmds = {
        }

        for _, command in pairs(generic_cmds) do
            local comps = {
                "on_output_summarize",
                "on_exit_set_status",
                "on_complete_notify",
                "on_complete_dispose",
            }

            table.insert(ret, {
                name = command.name,
                builder = function()
                    return {
                        name = command.tskName or command.name,
                        cmd = command.cmd,
                        components = comps,
                        metadata = {
                            is_test_server = command.is_test_server,
                        },
                    }
                end,
                tags = command.tags,
                priority = priority,
                params = {},
                condition = command.condition,
            })
            priority = priority + 1
        end

        table.insert(ret,
            {
                name = "C:: Run meson project",
                builder = function()
                    return {name = "Just run",
                        strategy = {
                            'orchestrator',
                            tasks = {
                                {'shell',  cmd = "just sdc"}, -- Setup
                                {'shell',  cmd = "just cd"}, -- Compile
                                {'shell', cmd = "just rd"} -- Run
                            },
                        }}
                end,
                priority = pr(),
            })

        cb(ret)
    end,
}

