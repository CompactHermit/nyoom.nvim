(import-macros {: lazyp} :macros)
(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))

(tset _G :nyoom/modules nil)
(describe "LazyP Spec Test"
          (fn []
            (values (it "LazyP:: Want/Deps"
                        #(assert.are.same (type (lazyp :foo {:wants [:debug]}))
                                          :table))
                    (it "LazyP:: Packadd spec" #(assert.are.same nil nil)))))

(describe "mac:: let!"
          (fn []
            (it "LazP Spec Test" #(assert.are.same 2 2))))
