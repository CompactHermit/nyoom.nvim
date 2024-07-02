(import-macros {: lzn! : lazyp} :macros)

; easy to use configurations for language servers

;; TODO:: Add proper `register_module` for custom defer
(lzn! :lspconfig {:nyoom-module tools.lsp
                  :event [:DeferredUIEnter]
                  :cmd [:LspInfo :LspLog :LspStart :LspRestart :LspStop]
                  :deps [:cmp-nvim-lsp]})

(lzn! :lspsaga
      {:event :LspAttach
       :wants [:lspconfig]
       :after #((->> :setup (. (require :lspsaga))) {:lightbulb {:enable false}})})
