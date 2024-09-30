(import-macros {: lzn!} :macros)

(lzn! :feed-nvim {:nyoom-module tools.feed
                  :wants [:telescope :which-key]
                  :cmd [:Feed]
                  :deps [:treedoc :conform]})
