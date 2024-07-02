(import-macros {: lzn!} :macros)

(lzn! :neotest {:nyoom-module tools.neotest
                :wants [:telescope :toggleterm :overseer]
                :deps [:neotest-haskell
                       :neotest-zig
                       :neotest-busted
                       :overseer
                       :rustaceanvim]
                :cmd [:Neotest]})
