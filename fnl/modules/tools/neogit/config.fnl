(import-macros {: augroup! : autocmd! : local-set! : packadd!} :macros)

(fn __neogitSetup []
  (packadd! neogit)
  (packadd! diffview)
  (if (= (pcall require :gitsigns) nil) (vim.api.nvim_exec_autocmds :gitsigns))
  (let [neogit (autoload :neogit)
        gitsigns (autoload :gitsigns)
        nio (autoload :nio)
        nr nio.run
        nf nio.future
        ne (nio.control.event)
        fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :neogit}})
        __augroup (vim.api.nvim_create_augroup :HermitGit {:clear true})
        aucmd vim.api.nvim_create_autocmd]
    (nr (fn []
          (vim.api.nvim_exec_autocmds :User {:pattern :diffview.setup})
          (ne.set)))
    (nr (fn []
          (ne.wait)
          (progress:report {:message "Setting Up Neogit"
                            :level vim.log.levels.TRACE
                            :progress 0})
          (neogit.setup {:disable_signs true
                         :disable_hint true
                         :disable_context_highlighting false
                         :integrations {:diffview true :telescope true}
                         :sections {:recent {:folded true}}})
          (progress:report {:message "Setup Complete"
                            :title :Completed!
                            :progress 99})))
    (aucmd :FileType {:pattern [:NeogitBranchDescription
                                :NeogitCommitMessage
                                :NeogitCommitView
                                :NeogitLogView
                                :NeogitMergeMessage
                                :NeogitPopup
                                :NeogitStatus
                                :NeogitTagMessage]
                      :callback #(set vim.b.toggle_line_style 0)
                      :group __augroup})
    (aucmd :User {:pattern [:NeogitCommitComplete
                            :NeogitPullComplete
                            :NeogitPushComplete
                            :NeogitStatusRefreshed]
                  :callback #(gitsigns.refresh)
                  :group __augroup})))

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds

;; fnlfmt: skip
(let [commands [:Neogit]]
  (each [_ cmd (ipairs commands)]
    (vim.api.nvim_create_user_command cmd
                                      (fn [args]
                                        (vim.api.nvim_del_user_command cmd)
                                        (__neogitSetup)
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
                                                   (__neogitSetup)
                                                   (vim.fn.getcompletion (.. cmd
                                                                             " ")
                                                                         :cmdline))
                                       :nargs "*"})))
