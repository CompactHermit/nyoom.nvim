(import-macros {: lzn!} :macros)

(lzn! :telescope {:nyoom-module completion.telescope
                  :cmd :Telescope
                  ;:on_require [:telescope :telescope.action :telescope.state]
                  :deps [:telescope-ui-select
                         :telescope-file-browse
                         :telescope-project
                         :telescope-zf-native
                         :telescope-zoxide
                         :telescope-tabs
                         :telescope-egrepify]
                  :wants [:folke_flash]})
