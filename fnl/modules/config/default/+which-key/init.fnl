(import-macros {: use-package!} :macros)

(use-package! :CompactHermit/which-key.nvim
              {:nyoom-module config.default.+which-key
               :module :which-key
               :keys [:<leader> "\"" "'" "`"]})
