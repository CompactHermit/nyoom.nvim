(import-macros {: lzn!} :macros)

;;TODO: (Hermit) make custom handler for tree-sitter, not using `deffereduienter`
(lzn! :nvim-treesitter
      {:nyoom-module tools.tree-sitter
       :deps [:ts-context-commentstring
              :ts-refactor
              :ts-textobjects
              :ts-node-action]
       :event [:DeferredUIEnter]
       :cmd [:TSBufToggle :TSModuleInfo]})

; (use-package! :nvim-treesitter/nvim-treesitter-context
;               {:opt true
;                :event [:BufWritePost]
;                :config (fn []
;                          (local {: setup} (require :treesitter-context))
;                          (setup {:enable true}))})
