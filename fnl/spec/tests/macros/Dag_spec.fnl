(import-macros {: lzn!} :macros {: t} :util.macros.test-macros)

(comment "
         dag-Specs::
         Since each plugin has colinear deps (as in, each dep is simply packadded, and are the same irrespective of /when/ they are loaded), we can abuse fennel macros to create a `minimal` load-tree. This is resolved via this dag.
         ")

; (local {: describe : it} (require :plenary.busted))
; (local assert (require :luassert.assert))

; (lua "describe (\"Directed Acyclic Graph in fennel\" ,
;                     function()
;                         it (\"ooga\",
;                             function()")
;
; (assert.are.same 1 1)
;
; (lua "end); end);")
