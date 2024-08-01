-- NOTE:: (Hermit) Make LuaLs shut the fuck up
---@diagnostic disable: lowercase-global
local _MODREV, _SPECREV = "scm", "-1"
rockspec_format = "3.0"
packages = "nyoom.nvim"
_VERSION = _MODREV .. _SPECREV

source = {
	url = "git://github.com/CompactHermit" .. package,
}

---NOTE:: (Hermit) There might be a way to hook the luarocks-build-hook to
--                      \-> make luarocks-hotpot-buildhook
build = {
	type = "fennel",
	provided = true,
	modules = {
		[""] = "",
	},
}
macro_modules = {
	["macros"] = "",
}

test = {
	type = "command",
	command = "nvim --clean ",
}

test_dependencies = {
	"lua = 5.1",
	"plenary.nvim",
	"hotpot",
	"nlua",
	"nio",
}
