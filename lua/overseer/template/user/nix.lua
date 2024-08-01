local files = require("overseer.files")

local isInProject = function(opts)
	return files.exists(files.join(opts.dir, "flake.nix")) or files.exists(files.join(opts.dir), "default.nix")
end

return {
	condition = {
		callback = function(opts)
			return vim.bo.filetype == "nix" or isInProject(opts)
		end,
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
			{
				name = "Nix:: Build Flake",
				tskname = "Nix Build",
				cmd = "nix build .#default -Lvv --show-trace",
				condition = {
					callback = isInProject,
				},
				unique = true,
			},
			{
				name = "Nix:: Check nixosConfig",
				tskname = "Nix Config build",
				cmd = "nixci .#nixosConfiguration.Kepler",
				condition = {
					callback = isInProject,
				},
				unique = true,
			},
			{
				name = "Nix run app (" .. vim.fn.expand("%:s") .. ")",
				tskName = "Nix:: Run App",
				cmd = "nix run .#default",
				condition = {
					callback = isInProject,
				},
				unique = true,
			},
			{
				name = "Nix:: Run Test",
				tskName = "Nix Unit Test",
				cmd = "nix flake check -Lvv",
				condition = {
					callback = isInProject,
				},

				unique = true,
			},
			{
				name = "Nix:: gen Lockfile",
				tskName = "Nix Flake Lock",
				cmd = "nix flake lock",
				condition = { callback = isInProject },
				hide = true,
				unique = true,
			},
			{
				name = "Nix Flake Show",
				unique = true,
				cmd = "nix flake show",
				condition = { filetype = "nix" },
			},
			{
				name = "Nix:: Show Logs",
				cmd = "nix log .#default",
				condition = {
					callback = isInProject,
				},
				unique = true,
			},
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

		table.insert(ret, {
			name = "Nix:: Orchestrated Build + Logs",
			builder = function()
				return {
					name = "- Build and Log",
					strategy = {
						"orchestrator",
						tasks = {
							{ "shell", cmd = "nix build ." }, -- Build
							{ "shell", cmd = "nix log ." }, -- Log
						},
					},
				}
			end,
			priority = pr(),
		})

		cb(ret)
	end,
}
