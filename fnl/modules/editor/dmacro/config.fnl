(import-macros {: packadd!} :macros)
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __dmacroSetup []
  " DMacros:: Better Macros, for less
  "
  (packadd! dynMacro)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :dmacro}})]
    (progress:report {:message "Setting Up DMacro"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :dmacro))) {:dmacro_key :<M-q>})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :BufReadPost
                             {:callback #(__dmacroSetup) :once true})
