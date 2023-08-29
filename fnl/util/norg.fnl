(import-macros {: nyoom-module-p!} :macros)

; local ls = require("luasnip")
; local s = ls.snippet
; local sn = ls.snippet_node
; local isn = ls.indent_snippet_node
; local t = ls.text_node
; local i = ls.insert_node
; local f = ls.function_node
; local c = ls.choice_node
; local d = ls.dynamic_node
; local r = ls.restore_node
; local events = require("luasnip.util.events")
; local ai = require("luasnip.nodes.absolute_indexer")
; local fmt = require("luasnip.extras.fmt").fmt
; local rep = require("luasnip.extras").rep
; local m = require("luasnip.extras").m
; local lambda = require("luasnip.extras").l
; local postfix = require("luasnip.extras.postfix").postfix
;
; local e = function(trig, name, dscr, wordTrig, regTrig, docstring, docTrig, hidden, priority)
;   local ret = { trig = trig, name = name, dscr = dscr}
;   if wordTrig ~= nil then ret["wordTrig"] = wordTrig end
;   if regTrig ~= nil then ret["regTrig"] = regTrig end
;   if docstring ~= nil then ret["docstring"] = docstring end
;   if docTrig ~= nil then ret["docTrig"] = docTrig end
;   if hidden ~= nil then ret["hidden"] = hidden end
;   if priority ~= nil then ret["priority"] = priority end
;   return ret
; end
;
; local tmpls = require("neorg.modules.external.templates.default_snippets")
; local M = {}
;
; M.keywords = {
;               YESTERDAY = function()
;               return i(1, tmpls.parse_date(-1, tmpls.file_title()))
;               end,
;               TOMORROW = function()
;               return i(1, tmpls.parse_date(1, tmpls.file_title()))
;               end,}
;
;
; return M

; local ls = require("luasnip")
; local s = ls.snippet
; local sn = ls.snippet_node
; local isn = ls.indent_snippet_node
; local t = ls.text_node
; local i = ls.insert_node
; local f = ls.function_node
; local c = ls.choice_node
; local d = ls.dynamic_node
; local r = ls.restore_node
; local events = require("luasnip.util.events")
; local ai = require("luasnip.nodes.absolute_indexer")
; local fmt = require("luasnip.extras.fmt").fmt
; local rep = require("luasnip.extras").rep
; local m = require("luasnip.extras").m
; local lambda = require("luasnip.extras").l
; local postfix = require("luasnip.extras.postfix").postfix
;
(nyoom-module-p! cmp
                 (let [ls (autoload :luansip)
                        s (. ls :snippet)
                        sn (. ls :snippet_node)
                        isn (. ls :indent_snippet_node)
                        t (. ls :text_node)
                        i (. ls :insert_node)
                        f (. ls :function_node)
                        c (. ls :choice_node)
                        d (. ls :dynamic_node)
                        r (. ls restore_node)
                        ;events (. (require :luasnip) :util :event)
                        ai (. (require :luasnip) :nodes :absolute_indexer)
                        fmt (. (require :luasnip) :extras :fmt)]))

