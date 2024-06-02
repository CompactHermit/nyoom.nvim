(import-macros {: packadd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __gitSignsSetup []
  " GitSigns::
  "
  (packadd! gitsigns)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :gitSigns}})]
    (progress:report {:message "Setting Up giSigns"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (autoload :gitsigns))) {:signs {:add {:hl :diffAdded
                                                          :text "│"
                                                          :numhl :GitSignsAddNr
                                                          :linehl :GitSignsAddLn}
                                                    :change {:hl :diffChanged
                                                             :text "│"
                                                             :numhl :GitSignsChangeNr
                                                             :linehl :GitSignsChangeLn}
                                                    :delete {:hl :diffRemoved
                                                             :text ""
                                                             :numhl :GitSignsDeleteNr
                                                             :linehl :GitSignsDeleteLn}
                                                    :changedelete {:hl :diffChanged
                                                                   :text "‾"
                                                                   :numhl :GitSignsChangeNr
                                                                   :linehl :GitSignsChangeLn}
                                                    :topdelete {:hl :diffRemoved
                                                                :text "~"
                                                                :numhl :GitSignsDeleteNr
                                                                :linehl :GitSignsDeleteLn}}})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

;(vim.api.nvim_create_augroup {:})
(vim.api.nvim_create_autocmd :BufRead {:once true :callback #(__gitSignsSetup)})
