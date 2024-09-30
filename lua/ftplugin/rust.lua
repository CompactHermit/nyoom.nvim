local bufnr = vim.api.nvim_get_current_buf()
local auOpts = {
	close_events = { BufLeave = "CursorMoved", InsertEnter = "FocusLost" },
	border = "rounded",
	source = "always",
	prefix = " ",
	scope = "line",
	focusable = false,
}

vim.api.nvim_create_augroup("RustLsp", { clear = true })

local function _1_()
	return vim.diagnostic.open_float(auOpts)
end
return vim.api.nvim_create_autocmd("CursorHold", { group = "RustLsp", buffer = bufnr, callback = _1_ })
