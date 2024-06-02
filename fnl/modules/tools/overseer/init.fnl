(import-macros {: lzn!} :macros)

(lzn! :overseer {:nyoom-module tools.overseer
                 :cmd [:OverseerRun
                       :OverseerToggle
                       :OverseerQuickAction
                       :OverseerTaskAction
                       :OverseerBuild
                       :OverseerLoadBundle
                       :OverseerRunCmd
                       :OverseerTemplate]})
