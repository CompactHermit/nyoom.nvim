(import-macros {: lzn!} :macros)

(lzn! :helpview-nvim {:nyoom-module lang.vimdoc
                      ;:event [:BufReadPre]
                      :ft [:help :txt]
                      ;:wants [:nvim-treesitter]
                      :call-setup helpview})
