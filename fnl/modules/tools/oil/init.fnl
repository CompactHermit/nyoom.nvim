(import-macros {: lzn!} :macros)

(lzn! :oil {:nyoom-module tools.oil
            :keys [{1 :<M-o> 2 #((. (require :oil) :open)) :desc "Oil::"}]
            :cmd :Oil})
