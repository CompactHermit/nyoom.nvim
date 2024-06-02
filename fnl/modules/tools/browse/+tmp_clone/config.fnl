(import-macros {: map! : nyoom-module-p! : packadd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __tmpCloneSetup []
  (packadd! tmpclone-nvim)
  (if (not (pcall require :telescope))
      (vim.api.nvim_exec_autocmds :User {:pattern :telescope.setup}))
  (let [fidget (autoload :fidget)
        progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :tmpClone}})
        clone-repo (fn []
                     (vim.ui.input {:prompt "Repo to clone?"}
                                   (fn [callback]
                                     ((. (autoload :tmpclone.core) :clone) (tostring callback)))))]
    (progress:report {:message "Setting Up tmpClone"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (autoload :tmpclone))))
    (map! [n] :<leader>qc `(clone-repo) {:desc "Clone Repo"})
    (map! [n] :<leader>qo :<cmd>TmpcloneOpen<cr> {:desc "Open Repo"})
    (map! [n] :<leader>qr :<Cmd>TmpcloneRemove<cr> {:desc "Remove Repo"})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :User
                             {:pattern :tmpclone.setup
                              :callback #(__tmpCloneSetup)
                              :once true})

(fn loader []
  (vim.api.nvim_exec_autocmds :User {:pattern :tmpclone.setup}))

;; fnlfmt: skip
(let [commands [:TmpcloneClone :TmpcloneOpen :TmpcloneRemove]]
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
