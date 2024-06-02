(import-macros {: lzn!} :macros)

(lzn! :syntax-tree-surfer
      {:nyoom-module editor.swap
       :cmd [:STSSwapPrevVisual
             :STSSelectChildNode
             :STSSwapNextVisual
             :STSSelectParentNode
             :STSSelectPrevSiblingNode
             :STSSelectNextSiblingNode
             :STSSelectCurrentNode
             :STSSelectMasterNode]})

(lzn! :iswap.nvim {:cmd [:ISwapWith
                         :ISwap
                         :ISwapNodeWith
                         :IMoveWith
                         :IMoveNodeWith
                         :IMove]
                   :call-setup iswap})
