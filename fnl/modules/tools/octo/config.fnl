(import-macros {: packadd!} :macros)

(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :Octo}})
      get_width vim.api.nvim_win_get_width]
  (progress:report {:message "Setting Up <Octo>"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :octo))))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 99}))
