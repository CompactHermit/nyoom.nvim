(import-macros {: use-package!} :macros)

(use-package! :vsedov/quicknote.nvim
              {:nyoom-module lang.neorg.+quicknote
               :branch :custom_filetype
               :opt true
               :event [:BufReadPost]})
