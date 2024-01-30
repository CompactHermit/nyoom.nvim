(import-macros {: use-package!} :macros)


(use-package! :nvimtools/none-ls.nvim
              {:nyoom-module checkers.diagnostics :after :nvim-lspconfig})

; (use-package! :stevearc/conform.nvim
              ; {:nyoom-module checkers.diagnostics :after :nvim-lspconfig})
