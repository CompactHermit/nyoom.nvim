local ls = require("luasnip")
-- Shorthanded notations
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt



--
-- --TODO:: fix these into proper snippets
-- --
-- --1 :Conditional
-- (cond (${1:test} ${2:then})
--       (t ${3:else}))
--
-- --2: Case
-- (case ${1:key-form}
--   (${2:match} ${3:result})${4:
--   (t ${5:otherwise})})
--
-- --3: Macro
-- (defmacro ${1:name} (${2:args }${3:&body body})${4:
--   "${5:doc}"}
--   $0)
--
-- --4: Def param
-- (defparameter *${1:name}* ${2:nil}${3:
--  "${4:doc}"})
-- $0
--
-- --5:If
-- (if ${1:test} ${2:then}${3: else})
--
-- --6 :defgeneric
-- (defgeneric ${1:name} (${2:args})${3:
--   (:documentation "${4:doc}")})
-- $0
--
-- --7:ctypecase
-- (ctypecase ${1:key-form}
--   (${2:match} ${3:result}))
--
-- --8: Assert
-- (assert ${1:assertion} (${2:vars-to-change})
--   "${3:string}"
--   ${4:mentioned-vars})
--
-- --9
--
-- --10
--
-- --11
--
-- --12
--
-- --13
--
-- --14
--
-- --15
--
-- --16
--
-- --17
--
-- --18
--
