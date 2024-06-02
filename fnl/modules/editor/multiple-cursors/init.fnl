(import-macros {: lzn!} :macros)

(lzn! :multicursor {:nyoom-module editor.multiple-cursors
                    :keys [{1 :<M-c>
                            2 #((. (require :multicursors) :start))
                            :desc "Buffer:: MCursor"}]
                    :wants [:hydra]
                    :cmds [:MCstart
                           :MCvisual
                           :MCpattern
                           :MCvisualPattern
                           :MCunderCursor
                           :MCclear]})
