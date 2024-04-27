(import-macros {: packadd!} :macros)
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds

(fn __iblSetup []
  (packadd! ibl)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :ibl}})
        nio (autoload :nio)
        ibl (require :ibl)
        hooks (require :ibl.hooks)]
    (nio.run (fn []
               (nio.scheduler)
               (progress:report {:message "Setting Up :: <IBL>"
                                 :level vim.log.levels.ERROR
                                 :progress 0})
               ((->> :setup (. (require :ibl))) {:indent {:char "▎"}
                                                 :scope {:char "┆"
                                                         :show_start false
                                                         :show_end false}
                                                 :exclude {:buftypes [:help
                                                                      :nofile
                                                                      :prompt
                                                                      :quickfix
                                                                      :nofile
                                                                      :oil
                                                                      :terminal]}})
               (nio.scheduler)
               ;(print "This is actually firing off more than once? The fuck")
               (hooks.register hooks.type.SCOPE_HIGHLIGHT
                               hooks.builtin.scope_highlight_from_extmark)
               (progress:report {:message "Setup Complete"
                                 :title :Completed!
                                 :progress 99})))))

(local _augroup (vim.api.nvim_create_augroup :ibl.setup {:clear true}))
(vim.api.nvim_create_autocmd [:BufReadPost :BufAdd :BufNewFile]
                             {:pattern "*"
                              :group :ibl.setup
                              :callback (fn []
                                          (__iblSetup)
                                          (vim.api.nvim_del_augroup_by_id _augroup))})
