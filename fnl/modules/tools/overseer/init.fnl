(import-macros {: lzn!} :macros)

(lzn! :overseer {:nyoom-module tools.overseer
                 :wants [:telescope :care]
                 :cmd [:OverseerRun
                       :OverseerToggle
                       :OverseerQuickAction
                       :OverseerTaskAction
                       :OverseerBuild
                       :OverseerLoadBundle
                       :OverseerRunCmd
                       :OverseerTemplate]})
