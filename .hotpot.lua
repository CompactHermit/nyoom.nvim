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
		--Turn down verbosity for now
		{ atomic = true, verbose = false },
		{ "fnl/util/macros/*.fnl", false },
		{ "fnl/**/*macros.fnl", false },
		{ "fnl/**/*macro*.fnl", false },
		{ "fnl/doctor/*.fnl", true },
		{
			"fnl/after/**/*.fnl",
			function(path)
				return path:gsub("fnl/after", "after")
			end,
		},
		{
			"fnl/ftplugin/*.fnl",
			function(path)
				return path:gsub("fnl/ftplugin", "lua/ftplugin")
			end,
			true,
		},
		-- { "deps/**/*.fnl", true},
		-- { "init.fnl",           true },
		-- { "fnl/**/*.fnl", function(path) --TODO:: Find way to access module-table from `modules.fnl`, if we can just pass `_G` args then their might be a way here
		--     -- NOTE: _G.enabled? has elems of form:: <modType>/<moduleName> e.g:: `ui/hydra`. IDK if we can access global vars with hotpot
		--     if (_G["nyoom/modules"]) then
		--     end
		-- end },
		{
			"fnl/spec/**/*.fnl",
			function(path)
				return path:gsub("fnl/spec", "lua/spec")
			end,
		},
	},
	clean = {
		{ "lua/spec/*.lua", false },
		{ "lua/overseer/**/user/*.lua", false },
	},
}
-- vim: ft=lua
