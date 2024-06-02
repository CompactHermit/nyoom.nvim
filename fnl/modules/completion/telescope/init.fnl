(import-macros {: lzn!} :macros)

; (use-package! :nvim-lua/telescope.nvim
;               {:nyoom-module completion.telescope
;                :module [:telescope]
;                :cmd :Telescope
;                :requires [()
;                           (pack :nvim-telescope/telescope-file-browser.nvim
;                           (pack :camgraff/telescope-tmux.nvim {:opt true})
;                           (pack :nvim-telescope/telescope-media-files.nvim
;                           (pack :nvim-telescope/telescope-project.nvim
;                           (pack :LukasPietzschmann/telescope-tabs {:opt true})
;                           (pack :HUAHUAI23/telescope-session.nvim {:opt true})
;                           (pack :jvgrootveld/telescope-zoxide {:opt true})
;                           (pack :fdschmidt93/telescope-egrepify.nvim
(lzn! :telescope {:nyoom-module completion.telescope
                  :cmd :Telescope
                  :deps [:telescope-ui-select
                         :telescope-file-browse
                         :folke_flash
                         :telescope-project
                         :telescope-tabs
                         :telescope-egrepify]
                  :event [:BufRead]})
