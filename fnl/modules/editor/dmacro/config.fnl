(import-macros {: packadd!} :macros)
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds

(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :dmacro}})]
  (progress:report {:message "Setting Up DMacro"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :dmacro))) {:dmacro_key :<M-q>})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100}))
