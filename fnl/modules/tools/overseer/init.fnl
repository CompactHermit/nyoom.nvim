(import-macros {: use-package!} :macros)

(use-package! :stevearc/overseer.nvim
              {:nyoom-module tools.overseer
               :opt true
               :cmd [:OverseerOpen!
                      :OverseerRun
                      :OverseerToggle]})

(use-package! :Zeioth/compiler.nvim
              {:opt true
               :dependecies ["stevearc/overseer.nvim"]
               :cmd [:CompilerOpen :CompilerToggleResults]
               :call-setup compiler})
