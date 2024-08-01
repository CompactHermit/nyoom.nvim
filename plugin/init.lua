vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	group = vim.api.nvim_create_namespace("faker"),
	callback = function()
		require("core.init")
		vim.schedule(function()
			require("lz.n").trigger_load("alpha")
			vim.api.nvim_exec_autocmds("VimEnter", {})
		end)
		require("lzn-auto-require.loader").register_loader()
	end,
})
