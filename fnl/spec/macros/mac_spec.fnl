(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))

(import-macros {: lazyp} :macros)

(describe "LazP:: Want/deps"
          (fn []
            (it "LazP Spec Test"
                (fn []
                  (assert.are.same (type (lazyp :name
                                                {:deps [:tbl :matter :ball]}))
                                   :table)))))
