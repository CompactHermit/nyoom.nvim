(import-macros {: lzn!} :macros)

(lzn! :dynMacro {:nyoom-module editor.dmacro
                 :keys [{1 :<M-q>
                         2 "<Plug>(dmacro-play-macro)"
                         :desc "Dmacro:: Exec Macro"}]})
