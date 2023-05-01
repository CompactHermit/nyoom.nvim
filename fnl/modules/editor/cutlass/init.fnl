(import-macros {: use-package!} :macros)

(use-package! :gbprod/yanky.nvim
              {:nyoom-module editor.cutlass
               :after :telescope.nvim
               :event :BufWrite})
