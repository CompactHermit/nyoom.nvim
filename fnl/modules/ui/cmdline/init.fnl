(import-macros {: lzn!} :macros)

(lzn! :cmdline {:nyoom-module :ui.cmdline
                :load (fn [])
                :event [:DeferredUIEnter]})
