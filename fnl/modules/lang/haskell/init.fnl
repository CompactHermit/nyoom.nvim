(import-macros {: lzn!} :macros)

(lzn! :haskellTools {:ft [:haskell :cabal]
                     :nyoom-module lang.haskell
                     :deps [:telescope_hoogle]
                     :wants [:toggleterm :telescope]})
