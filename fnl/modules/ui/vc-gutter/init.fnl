(import-macros {: nyoom-module! : lzn!} :macros)

(lzn! :gitsigns {:nyoom-module ui.vc-gutter
                 :enabled (fn []
                            (vim.fn.system (.. "git -C "
                                               (vim.fn.expand "%:p:h")
                                               " rev-parse"))
                            (if (= vim.v.shell_error 0) true false))
                 :cmd [:Gitsigns]})
