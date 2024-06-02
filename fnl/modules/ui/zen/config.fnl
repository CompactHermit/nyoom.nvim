(import-macros {: packadd!} :macros)

(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :zen}})]
  (progress:report {:message "Setting Up zen"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :true-zen))))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100}))
