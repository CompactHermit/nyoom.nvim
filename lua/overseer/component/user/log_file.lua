return {
	desc = "Launch Nix log",
	editable = false,
	serializable = true,
	params = {
		send_on_open = {
			type = "string",
			desc = "What Drv are we checking for the flake",
			default = "#default",
			optional = true,
		},
	},
	constructor = function(params)
		return {
			run_after = function(_, task)
				if params.send_on_open then
					vim.fn.chansend(task.strategy.chan_id, params.send_on_open)
				end
			end,
		}
	end,
}
