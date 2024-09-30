(import-macros {: lzn!} :macros)

(lzn! :which-key {:nyoom-module config.default.+which-key
                  :event [:DeferredUIEnter]
                  :cmd [:WhichKey]
                  :keys [:<leader> ";"]})

; (lzn! :coerce {:keys [:cr]
;                :after #()})
