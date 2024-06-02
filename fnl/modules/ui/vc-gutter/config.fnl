(import-macros {: packadd!} :macros)

;; fnlfmt: skip
(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :gitSigns}})]
  (progress:report {:message "Setting Up giSigns"
                    :level vim.log.levels.ERROR
                    :progress 0}
   ((->> :setup (. (autoload :gitsigns))) {}))
         ;{:signs {:add {:hl :diffAdded}}})))
  ;                                                       :text "│"
  ;                                                       :numhl :GitSignsAddNr
  ;                                                       :linehl :GitSignsAddLn}
  ;                                                 :change {:hl :diffChanged
  ;                                                          :text "│"
  ;                                                          :numhl :GitSignsChangeNr
  ;                                                          :linehl :GitSignsChangeLn}
  ;                                                 :delete {:hl :diffRemoved
  ;                                                          :text ""
  ;                                                          :numhl :GitSignsDeleteNr
  ;                                                          :linehl :GitSignsDeleteLn}
  ;                                                 :changedelete {:hl :diffChanged
  ;                                                                :text "‾"
  ;                                                                :numhl :GitSignsChangeNr
  ;                                                                :linehl :GitSignsChangeLn}
  ;                                                 :topdelete {:hl :diffRemoved
  ;                                                             :text "~"
  ;                                                             :numhl :GitSignsDeleteNr
  ;                                                             :linehl :GitSignsDeleteLn}}})
  (vim.api.nvim_set_hl 0 :GitSignsAdd {:link :diffAdded})
  (vim.api.nvim_set_hl 0 :GitSignsAddLn {:link :GitSignsAddLn})
  (vim.api.nvim_set_hl 0 :GitSignsAddNr {:link :GitSignsAddNr})
  (vim.api.nvim_set_hl 0 :GitSignsChange {:link :diffChanged})
  (vim.api.nvim_set_hl 0 :GitSignsChangeLn {:link :GitSignsChangeLn})
  (vim.api.nvim_set_hl 0 :GitSignsChangeNr {:link :GitSignsChangeNr})
  (vim.api.nvim_set_hl 0 :GitSignsChangedelete {:link :diffChanged})
  (vim.api.nvim_set_hl 0 :GitSignsChangedeleteLn {:link :GitSignsChangeLn})
  (vim.api.nvim_set_hl 0 :GitSignsChangedeleteNr {:link :GitSignsChangeNr})
  (vim.api.nvim_set_hl 0 :GitSignsDelete {:link :diffRemoved})
  (vim.api.nvim_set_hl 0 :GitSignsDeleteLn {:link :GitSignsDeleteLn})
  (vim.api.nvim_set_hl 0 :GitSignsDeleteNr {:link :GitSignsDeleteNr})
  (vim.api.nvim_set_hl 0 :GitSignsTopdelete {:link :diffRemoved})
  (vim.api.nvim_set_hl 0 :GitSignsTopdeleteLn {:link :GitSignsDeleteLn})
  (vim.api.nvim_set_hl 0 :GitSignsTopdeleteNr {:link :GitSignsDeleteNr})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))

;(vim.api.nvim_create_autocmd :BufRead {:once true :callback #(__gitSignsSetup)})
