(import-macros {: packadd!} :macros)
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __ttermSetup []
  (packadd! toggleterm)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :tterm}})]
    (progress:report {:message "Setting Up tterm"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :toggleterm))))
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :User
                             {:pattern :toggleterm.setup
                              :callback #(__ttermSetup)
                              :once true})

(fn loader []
  (vim.api.nvim_exec_autocmds :User {:pattern :toggleterm.setup}))

;; fnlfmt: skip
(let [commands [:ToggleTerm]]
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
