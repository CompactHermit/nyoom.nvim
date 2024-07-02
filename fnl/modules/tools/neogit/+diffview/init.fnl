(import-macros {: lzn!} :macros)

(lzn! :diffview {:nyoom-module tools.neogit.+diffview
                 :cmd [:DiffviewFileHistory
                       :DiffviewOpen
                       :DiffviewClose
                       :DiffviewToggleFiles
                       :DiffviewFocusFiles
                       :DiffviewRefresh]})
