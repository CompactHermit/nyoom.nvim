(import-macros {: use-package!} :macros)

(use-package! :pmizio/typescript-tools.nvim
              {:nyoom-module lang.typescript
               :opt true
               :event [:BufReadPost]
               :ft [:ts :tsx]})
