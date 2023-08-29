(import-macros {: packadd!} :macros)

(packadd! :otter.nvim)
(setup {:lspFeatures {:enabled true}
            :languages [:r :python :julia :haskell]
            :diagnostics {:enabled true :triggers [:BufWritePost]}})
