(import-macros {: lzn!} :macros)

(lzn! :which-key {:nyoom-module config.default.+which-key
                  :event [:BufRead]
                  :keys [:<leader>]})
