(import-macros {: lzn! : lazyp} :macros)

; easy to use configurations for language servers

;; TODO:: Add proper `register_module` for custom defer
(lzn! :lspconfig {:nyoom-module tools.lsp :event [:BufReadPre]})

(lzn! :lspsaga
      {:event :LspAttach
       :after #((->> :setup (. (require :lspsaga))) {:lightbulb {:enable false}})})
