(import-macros {: packadd!} :macros)

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
             (hooks.register hooks.type.SCOPE_HIGHLIGHT
                             hooks.builtin.scope_highlight_from_extmark)
             (progress:report {:message "Setup Complete"
                               :title "Indent BlankLine"
                               :progress 100})
             (progress:finish))))
