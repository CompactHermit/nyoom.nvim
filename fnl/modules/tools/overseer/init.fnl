(import-macros {: use-package!} :macros)

(use-package! :stevearc/overseer.nvim
              {:nyoom-module tools.overseer
               :opt true
               :cmd [:OverseerOpen!
                      :OverseerRun
                      :OverseerToggle]})

