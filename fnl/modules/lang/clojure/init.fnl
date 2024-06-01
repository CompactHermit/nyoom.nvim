(import-macros {: use-package!} :macros)

(use-package! :julienvincent/nvim-paredit
              {:nyoom-module lang.clojure :event :BufReadPre})
