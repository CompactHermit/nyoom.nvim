(import-macros {: lzn!} :macros)

(lzn! :yanky {:nyoom-module editor.cutlass
              :cmd [:Yanky]
              :wants [:telescope]
              :event [:TextYankPost]
              :keys [:Y :y :p :P :vey]})
