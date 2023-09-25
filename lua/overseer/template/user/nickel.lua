local files = require("overseer.files")

local isInProject = function(opts)
    return files.exists(files.join(opts.dir, "flake.nix")) or files.exists(files.join(opts.dir), "project.ncl")
end

return {
    condition = {
        callback = function(opts)
            return vim.bo.filetype=="nickel" or isInProject(opts)
        end
    },
    generator = function(_, cb)
        local ret = {}
        local priority = 60
        local pr = function()
            priority = priority + 1
            return priority
        end
        -- Run File
        table.insert(ret,{
            name = "Nickel:: Run file",
            builder = function()
                local file = vim.fn.expand("%:p")
                local cmd = {"nickel", "-f", file}
                return {
                    name = "Nickel Run",
                    cmd = cmd,
                    components = { "default", "on_output_summarize", "on_complete_notify",},
                }
            end,
            priority = pr(),
        })

        -- Topiary Diagnostics
        table.insert(ret, {
            name = "Topiary:: Fmt (" .. vim.fn.expand("%:t:r")..")",
            builder = function ()
                local file = vim.fn.expand("%:p")
                local cmd = {"topiary", "fmt", file}
                return {
                    name = "topiary fmt",
                    cmd = cmd,
                    components = {"default"}
                }
            end,
            priority = pr(),
        })

        cb(ret)
    end,
}
