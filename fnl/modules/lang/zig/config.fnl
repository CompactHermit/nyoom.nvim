(import-macros {: let!} :macros)

(let [fidget (autoload :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :zig}})]
  (progress:report {:message "Setting Up zig"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :zig-tools))) {:expose_commands true
                                          :formatter {:enable false}
                                          :terminal {:direction :horizontal
                                                     :close_on_exit false
                                                     :auto_scroll true
                                                     :terminal_mappings true}
                                          :checker {:enable true
                                                    :before_compilation true}
                                          :project {:flags {:build :--prominent-compile-errors}
                                                    :build_tasks true
                                                    :live_reload true
                                                    :auto_compile {:enable false
                                                                   :run true}}
                                          :integrations {:package_managers {}
                                                         :zls {:hints true
                                                               :management {:enable false}}}})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 99}))
