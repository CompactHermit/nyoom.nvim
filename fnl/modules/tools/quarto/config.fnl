(import-macros {: nyoom-module-p!} :macros)

(setup {:lspFeatures {:enabled true}
            :languages [:r :python :julia :haskell]
            :diagnostics {:enabled true :triggers [:BufWritePost]}})
