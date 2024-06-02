(import-macros {: packadd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __zenSetup []
  " true-Zen::"
  (packadd! truezen)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :zen}})]
    (progress:report {:message "Setting Up zen"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :true-zen))))
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :User
                             {:pattern :zen.setup
                              :callback #(__zenSetup)
                              :once true})

(fn loader []
  (vim.api.nvim_exec_autocmds :User {:pattern :zen.setup}))

;; fnlfmt: skip
(let [commands [:TZAtaraxis :TZNarrow :TZFocus :TZMinimalist :TZAtaraxis]]
  (each [_ cmd (ipairs commands)]
    (vim.api.nvim_create_user_command cmd
                                      (fn [args]
                                        (vim.api.nvim_del_user_command cmd)
                                        (loader)
                                        (vim.cmd (string.format "%s %s%s%s %s"
                                                                (or args.mods
                                                                    "")
                                                                (or (and (= args.line1
                                                                            args.line2)
                                                                         "")
                                                                    (.. args.line1
                                                                        ","
                                                                        args.line2))
                                                                cmd
                                                                (or (and args.bang
                                                                         "!")
                                                                    "")
                                                                args.args)))
                                      {:bang true
                                       :complete (fn []
                                                   (vim.api.nvim_del_user_command cmd)
                                                   (loader)
                                                   (vim.fn.getcompletion (.. cmd
                                                                             " ")
                                                                         :cmdline))
                                       :nargs "*"})))
