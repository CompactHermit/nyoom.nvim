(import-macros {: lzn!} :macros)

(lzn! :harpoon {:nyoom-module tools.harpoon
                :cmd [:Harp]
                :deps [:oqt :yeet]
                :wants [:overseer]})
