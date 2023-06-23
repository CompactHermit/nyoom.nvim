(import-macros {: use-package!} :macros)

;; TODO:: decrease formating and other junk by server, it's very slow for whatever reason
(use-package! :MrcJkb/haskell-tools.nvim
              {:nyoom-module lang.haskell
               :ft [:haskell]})

(use-package! :MrcJkb/haskell-snippets.nvim
              {:ft [:haskell]})
