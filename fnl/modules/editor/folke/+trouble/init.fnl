(import-macros {: lzn!} :macros)

(lzn! :folke_trouble {:nyoom-module editor.folke.+trouble
                      ;:event :BufReadPost
                      :cmd [:Trouble :TodoLocList :TodoQuickFix]
                      :wants [:gitsigns]
                      :deps [:folke_todo-comments]})
