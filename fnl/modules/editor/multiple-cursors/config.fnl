(import-macros {: packadd! : map!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __multiCursorSetup []
  (packadd! multicursor)
  (let [fidget (require :fidget)
        nio (autoload :nio)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :multiCursor}})]
    (progress:report {:message "Setting Up multiCursor"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ;;NOTE(Hemrit): This will never check for failure, look into a nio function which softwraps errors
    ((->> :setup (. (require :multicursors))) {})
    (map! [n] :<M-c> `((->> :start (. (require :multicursors))))
          {:desc "Buffer:: MultiCursor"})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :User
                             {:pattern :multicursor.setup
                              :callback #(__multiCursorSetup)
                              :once true})

;; fnlfmt: skip
(let [commands [:MCstart :MCvisual :MCpattern :MCvisualPattern :MCunderCursor :MCclear]]
  (each [_ cmd (ipairs commands)]
    (vim.api.nvim_create_user_command cmd
                                      (fn [args]
                                        (vim.api.nvim_del_user_command cmd)
                                        (vim.api.nvim_exec_autocmds :User {:pattern :multicursor.setup})
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
                                                   (vim.api.nvim_exec_autocmds :User {:pattern :multicursor.setup})
                                                   (vim.fn.getcompletion (.. cmd
                                                                             " ")
                                                                         :cmdline))
                                       :nargs "*"})))
