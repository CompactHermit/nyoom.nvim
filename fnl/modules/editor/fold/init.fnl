(import-macros {: use-package! : nyoom-module!} :macros)

; (use-package! :kevinhwang91/nvim-ufo
;               {:nyoom-module editor.fold
;                :after :nvim-treesitter
;                :requires [(pack :kevinhwang91/promise-async {:opt true})]})

(nyoom-module! editor.fold)
