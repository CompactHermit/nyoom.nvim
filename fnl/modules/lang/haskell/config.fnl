(import-macros {: nyoom-module-p!} :macros)
(local ht_attach (. (require :haskell-tools) :start_or_attach))

(nyoom-module-p! haskell
                 (do
                   (local tools {:codelens {:autorefresh false}})
                   (ht_attach tools)))


