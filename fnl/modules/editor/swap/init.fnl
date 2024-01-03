(import-macros {: use-package!} :macros)

(use-package! :ziontee113/syntax-tree-surfer
              {:opt true
               :nyoom-module editor.swap
               :cmd ["STSSwapPrevVisual"
                     "STSSelectChildNode"
                     "STSSwapNextVisual"
                     "STSSelectParentNode"
                     "STSSelectPrevSiblingNode"
                     "STSSelectNextSiblingNode"
                     "STSSelectCurrentNode"
                     "STSSelectMasterNode"]})

(use-package! :mizlan/iswap.nvim
              {:opt true
               :cmd [:ISwapWith
                     :ISwap
                     :ISwapNodeWith
                     :IMoveWith
                     :IMoveNodeWith
                     :IMove]
               :call-setup iswap})
