
 local default_plugins = {"2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat", "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "matchit", "tar", "tarPlugin", "rrhelper", "spellfile_plugin", "vimball", "vimballPlugin", "zip", "zipPlugin", "tutor", "rplugin", "syntax", "synmenu", "optwin", "compiler", "bugreport"}


























 local default_providers = {"node", "perl", "ruby"}

 for _, plugin in pairs(default_plugins) do vim.g[("loaded_" .. plugin)] = 1 end
 for _, provider in ipairs(default_providers) do
 vim.g[("loaded_" .. provider .. "_provider")] = 0 end




 require("hotpot").setup({enable_hotpot_diagnostics = true, provide_require_fennel = true, compiler = {macros = {allowGlobals = true, compilerEnv = _G, env = "_COMPILER"}, modules = {correlate = true, useBitLib = true}}})










 local stdlib = require("core.lib")
 for k, v in pairs(stdlib) do rawset(_G, k, v) end
 return require("core")
