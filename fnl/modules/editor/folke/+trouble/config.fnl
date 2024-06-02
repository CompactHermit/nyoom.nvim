(import-macros {: custom-set-face! : packadd!} :macros)

(let [fidget (require :fidget)
      _cprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :todo-comments}})
      _tprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :trouble}})
      _commOpts {:keywords {:REFACTOR {:icon "󰷦 "
                                       :color "#2563EB"
                                       :alt [:REF :REFCT :REFACT]}
                            :TEST {:icon "󰙨"}
                            :DOC {:icon ""
                                  :color "#a1eeff"
                                  :alt [:docs :doc :DOCS :dcx :dc]}
                            :TYPE {:icon " "}}}]
  (_cprogress:report {:message "Setting Up TodoComments::"
                      :level vim.log.levels.ERROR
                      :progress 10})
  ((->> :setup (. (require :todo-comments))) _commOpts)
  (_tprogress:report {:message "Setting Up Trouble"
                      :level vim.log.levels.ERROR
                      :progress 10})
  ((->> :setup (. (require :trouble))))
  (_tprogress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})
  (_cprogress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99}))
