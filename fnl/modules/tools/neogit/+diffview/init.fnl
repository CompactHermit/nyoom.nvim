(import-macros {: lzn!} :macros)

; (use-package! :sindrets/diffview.nvim
;               {:nyoom-module tools.neogit.+diffview
;                :opt true
(lzn! :diffview {:nyoom-module tools.neogit.+diffview
                 :cmd [:DiffviewFileHistory
                       :DiffviewOpen
                       :DiffviewClose
                       :DiffviewToggleFiles
                       :DiffviewFocusFiles
                       :DiffviewRefresh]})
