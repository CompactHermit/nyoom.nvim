(import-macros {: lzn!} :macros)

(lzn! :yanky {:nyoom-module editor.cutlass
              :cmd [:Yanky]
              :wants [:telescope]
              :event [:TextYankPost]
              :keys [{1 :p
                      2 "<Plug>(YankyPutAfter)"
                      :mode [:n :x]
                      :desc "[Ynk]P [A]fter"}
                     {1 :P
                      2 "<Plug>(YankyPutBefore)"
                      :mode [:n :x]
                      :desc "[Ynk]P [B]efore"}
                     {1 :gp
                      2 "<Plug>(YankyGPutAfter)"
                      :mode [:n :x]
                      :desc "[Ynk]gP [A]fter"}
                     {1 :gP
                      2 "<Plug>(YankyGPutBefore)"
                      :mode [:n :x]
                      :desc "[Ynk]gP [B]efore"}]})
