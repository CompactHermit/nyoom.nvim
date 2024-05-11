(import-macros {: packadd! : autocmd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __ressesion []
  "
    Resession::
  "
  (packadd! resession)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :ReSession}})
        __opts {:autosave {:enabled false} :load_order :filename}]
    (progress:report {:message "Setting Up ReSession"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :resession))) __opts)
    (progress:report {:message :ReSession
                      :title "Setting Up Autocmds"
                      :progress 99})
    ;(vim.api.nvim_create_autocmd :VimEnter {:callback (fn [])})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(do
  (vim.api.nvim_create_autocmd :User
                               {:pattern :resession.setup
                                :callback #(__ressesion)
                                :once true}))
