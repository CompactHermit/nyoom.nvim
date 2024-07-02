(import-macros {: lzn!} :macros)

(lzn! :telescope {:nyoom-module completion.telescope
                  :cmd :Telescope
                  :on_require [:telescope :telescope.action :telescope.state]
                  :deps [:telescope-ui-select
                         :telescope-file-browse
                         :folke_flash
                         :telescope-project
                         :telescope-tabs
                         :telescope-egrepify]
                  :event [:BufRead]})
