return {
    compiler = {
        macros = {
            allowGlobals = true,
            env = "_COMPILER",
            compilerEnv = _G,
        },
        modules = {
            correlate = true,
            useBitLib = true,
        },
    },
    build = {
        { atomic = true,        verbose = true },
        { "fnl/**/*macros.fnl", false },
        { "fnl/**/*macro*.fnl", false },
        -- { "init.fnl",           true },
        -- { "fnl/**/*.fnl", function(path) --TODO:: Find way to access module-table from `modules.fnl`, if we can just pass `_G` args then their might be a way here
        --     -- NOTE: _G.enabled? has elems of form:: <modType>/<moduleName> e.g:: `ui/hydra`. IDK if we can access global vars with hotpot
        --     if (_G["nyoom/modules"]) then
        --     end
        -- end },
        --{ "after/**/*.fnl",     true },
        { "fnl/spec/**/*.fnl", function(path)
            return path:gsub("fnl/spec", "lua/spec")
        end },
    },
    clean = {
        --{ "lua/**/*.lua",               true },
        { "lua/overseer/**/user/*.lua", false }
    }
}
-- vim: ft=lua
