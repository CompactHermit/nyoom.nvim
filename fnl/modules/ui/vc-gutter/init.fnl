(import-macros {: nyoom-module! : lzn!} :macros)

(lzn! :gitsigns {:nyoom-module ui.vc-gutter
                 :enabled #(let [opt (vim.system [:git
                                                  :rev-parse
                                                  :--absolute-git-dir])
                                 cb (: opt :wait)]
                             (values (= cb.stderr "")))
                 :event [:DeferredUIEnter]
                 :cmd [:Gitsigns]})
