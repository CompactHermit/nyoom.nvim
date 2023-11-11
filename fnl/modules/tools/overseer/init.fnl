(import-macros {: use-package!} :macros)
;
(use-package! :stevearc/overseer.nvim
              {:nyoom-module tools.overseer
               :commit :5e8498131867cd1b7c676ecdd1382ab2fd347dde
               :opt true
               :cmd [:OverseerRunCmd :OverseerRunCmd :OverseerToggle]})
