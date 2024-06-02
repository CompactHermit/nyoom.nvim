(import-macros {: lzn!} :macros)

(lzn! :nonels {:nyoom-module checkers.diagnostics
               :wants [:lspconfig :gitsigns]
               :event [:BufReadPost]})

;(nyoom-module! checkers.diagnostics)
