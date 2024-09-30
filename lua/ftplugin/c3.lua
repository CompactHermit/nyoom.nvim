if vim.fn.executable("c3c") then
	local compiler = "c3c"

	vim.g["compiler"] = "c3c"
	vim.g["makeprg"] = "c3c"
	return nil
else
	return nil
end
