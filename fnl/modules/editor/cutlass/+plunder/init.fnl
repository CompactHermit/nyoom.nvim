(import-macros {: lzn!} :macros)

(lzn! :substitute {:nyoom-module editor.cutlass.+plunder
                   :wants [:yanky]
                   :keys [{:mode :n
                           1 :s
                           2 #((. (require :substitute) :operator))
                           :desc :substitute}
                          {:mode :n
                           1 :ss
                           2 #((. (require :substitute) :line))
                           :desc :substitute-line}
                          {:mode :n
                           1 :S
                           2 #((. (require :substitute) :eol))
                           :desc :substitute-eol}
                          {:mode :x
                           1 :s
                           2 #((. (require :substitute) :visual))
                           :desc :substitute}]})
