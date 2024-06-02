(import-macros {: lzn!} :macros)

(lzn! :folke_trouble {:nyoom-module editor.folke.+trouble
                      :event :BufReadPost
                      :cmd [:Trouble :Todo]
                      :wants [:gitsigns]
                      :deps [:folke_todo-comments]})
