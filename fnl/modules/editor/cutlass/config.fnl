(import-macros {: packadd! : nyoom-module-p!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(let [__yankOpts {:ring {:history_length 100
                         :sync_with_numbered_registers true}
                  :system_clipboard {:sync_with_ring true}}
        fidget (autoload :fidget)
        progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :yanky}})]
    (progress:report {:message "Setting Up Module Name"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (autoload :yanky))) __yankOpts)
    (nyoom-module-p! telescope
                     ((->> :load_extension (. (autoload :telescope))) :yank_history))
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99}))

