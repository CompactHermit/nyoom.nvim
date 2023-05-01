(import-macros {: use-package!} :macros)

(use-package! :gbprod/substitute.nvim
               {:nyoom-module editor.cutlass.+plunder
                :event :BufReadPost})
