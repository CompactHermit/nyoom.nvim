(import-macros {: lzn!} :macros)

;; view binding
;(nyoom-module! config.default.+binding)
; (use-package! :ggandor/leap.nvim
;               {:nyoom-module config.default.+bindings
;                :requires [(pack :tpope/vim-repeat)
;                           (pack :ggandor/leap-ast.nvim {:opt true})
(lzn! :comment
      {:nyoom-module config.default.+bindings
       :event :DeferredUIEnter
       :keys [:<leader>c :gb]})
