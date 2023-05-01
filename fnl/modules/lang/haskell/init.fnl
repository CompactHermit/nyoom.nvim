(import-macros {: use-package!} :macros)

(use-package! :MrcJkb/haskell-tools.nvim
              {:nyoom-module lang.haskell
               :call-setup haskell-tools
               :ft [:haskell]})


