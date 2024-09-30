(import-macros {: lzn!} :macros)

(lzn! :quickfix {:call-setup bqf :cmd :BqfAutoToggle :ft [:qf]})
(lzn! :quicker-nvim {:nyoom-module tools.quickfix
                     :ft [:qf]
                     :wants [:quickfix]
                     :keys [{1 ";q"
                             2 #((. (require :quicker) :toggle))
                             :desc "[Q]f [To]ggle"}
                            ]})
