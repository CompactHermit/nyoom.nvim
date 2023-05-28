(import-macros {: use-package!} :macros)

(use-package! :MrcJkb/haskell-tools.nvim
              {:nyoom-module lang.haskell
               :call-setup haskell-tools
               :ft [:haskell]})

(use-package! :MrcJkb/haskell-snippets.nvim
              {:ft [:haskell]})
