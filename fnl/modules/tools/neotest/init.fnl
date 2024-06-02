(import-macros {: lzn!} :macros)

(lzn! :neotest {:nyoom-module tools.neotest
                :wants [:telescope :toggleterm]
                :deps [:neotest-haskell
                       :neotest-zig
                       :neotest-busted
                       :overseer
                       :rustaceanvim]
                :cmd [:Neotest]})
