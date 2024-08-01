; (local {: describe : it} (require :plenary.busted))
; (local assert (require :luassert.assert))

(describe :Something #(it :faker #(assert.are.same 1 1)))
