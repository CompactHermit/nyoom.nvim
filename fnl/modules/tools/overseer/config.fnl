(import-macros {: packadd!} :macros)
; {: lazy!} :util.macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __overseerSetup []
  (packadd! :overseer)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :overseer}})
        close-task (. (require :util.overseer) :close-task)
        util (require :overseer.util)
        STATUS (. (require :overseer.constants) :STATUS)
        Border ["🭽" "▔" "🭾" "▕" "🭿" "▁" "🭼" "▏"]
        __opts {:actions {"don't dispose" {:desc "keep the task until manually disposed"
                                           :run (fn [task]
                                                  (task:remove_components [:on_complete_dispose]))}
                          "dump task" {:desc "save task table to DumpTask (for debugging)"
                                       :run (fn [task]
                                              (local DumpTask task))}
                          "keep runnning" {:desc "restart the task even if it succeeds"
                                           :run (fn [task]
                                                  (task:add_components [{1 :on_complete_restart
                                                                         :statuses [STATUS.FAILURE
                                                                                    STATUS.SUCCESS]}])
                                                  (when (or (= task.status
                                                               STATUS.FAILURE)
                                                            (= task.status
                                                               STATUS.SUCCESS))
                                                    (task:restart)))}
                          :unwatch {:desc "stop from running on finish or file watch"
                                    :run (fn [task]
                                           (each [_ component (pairs [:on_complete_restart
                                                                      :on_complete_restart])]
                                             (when (task:has_component component)
                                               (task:remove_components [component]))))
                                    :condition (fn [task]
                                                 (or (task:has_component :on_complete_restart))
                                                 (task:has_component :restart_on_save))}
                          "open here" {:desc "open as bottom panel"
                                       :run (fn [task]
                                              (tset (. vim.bo
                                                       task.strategy.bufnr)
                                                    :filetype :OverseerTask)
                                              (vim.api.nvim_win_set_buf 0
                                                                        (task:get_bufnr))
                                              (set vim.wo.statuscolumn "%s")
                                              (util.scroll_to_end 0))
                                       :condition (fn [task]
                                                    (let [bufnr (task:get_bufnr)]
                                                      (and bufnr
                                                           (vim.api.nvim_buf_is_valid bufnr))))}
                          "set as reciever" {:desc "Sets tasks as terminal to recieve commands"
                                             :run (fn [task]
                                                    (local SendID
                                                           task.strategy.chan_id))}
                          :open {:desc "Open As bottom Panel"
                                 :run (fn [task]
                                        (vim.notify "Runner: opening task")
                                        (vim.cmd "normal! m'")
                                        (close-task task.strategy.bufnr)
                                        (tset (. vim.bo task.strategy.bufnr)
                                              :filetype :OverseerPanelTask)
                                        (vim.cmd.vsplit)
                                        (vim.api.nvim_win_set_buf 0
                                                                  (task:get_bufnr))
                                        (util.scroll_to_end 0))
                                 :condition (fn [task]
                                              (local bufnr (task:get_bufnr))
                                              (and bufnr
                                                   (vim.api.nvim_buf_is_valid bufnr)))}}
                :auto_detect_success_color true
                ;;:confirm {:border Border :win_opts {:winblend 0}}
                :component_aliases {:always_restart {1 :on_complete_restart
                                                     :statuses [STATUS.FAILURE
                                                                STATUS.SUCCESS]}
                                    :default [:on_output_summarize
                                              :on_exit_set_status
                                              {1 :on_complete_notify
                                               :system :unfocused}
                                              :on_complete_dispose
                                              :display_duration]
                                    :default_neotest [:on_output_summarize
                                                      :on_exit_set_status
                                                      [:on_complete_notify]
                                                      :on_complete_dispose
                                                      :unique
                                                      :display_duration]}
                :dap true
                :form {:border Border :win_opts {:winblend 0}}
                :strategy :terminal
                :task_editor {:border Border :win_opts {:winblend 0}}
                :task_win {:border Border :win_opts {:winblend 0}}
                :task_list {:separator "───────────────────────────────────────────────────────────────────────────────"
                            :bindings {:<C-e> :Edit
                                       :<C-f> :OpenFloat
                                       :<C-s> :OpenSplit
                                       :<C-v> :OpenVsplit
                                       :<CR> :RunAction
                                       :? :ShowHelp
                                       :H :DecreaseAllDetail
                                       :L :IncreaseAllDetail
                                       :O :Open
                                       "[" :DecreaseWidth
                                       "]" :IncreaseWidth
                                       :h :DecreaseDetail
                                       :l :IncreaseDetail
                                       :p :TogglePreview
                                       "{" :PrevTask
                                       "}" :NextTask}
                            :direction :left
                            :min_height 20
                            :height (math.floor (* vim.o.lines 0.3))
                            :max_height 40}
                :templates [:cargo
                            :just
                            :make
                            :npm
                            :shell
                            :tox
                            :vscode
                            :task
                            :user]}]
    (progress:report {:message "Setting Up OverSeer"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :overseer))) __opts)
    (progress:report {:message "Setup Overseer"
                      :title :Completed!
                      :progress 99})))

;;(nio.sleep )))

(vim.api.nvim_create_autocmd :User
                             {:pattern :overseer.setup
                              :callback #(__overseerSetup)
                              :once true})

(fn loader []
  (vim.api.nvim_exec_autocmds :User {:pattern :overseer.setup}))

;; fnlfmt: skip
(let [commands [:OverseerRunCmd :OverseerToggle]]
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
                                                   ;(loader)
                                                   (vim.fn.getcompletion (.. cmd
                                                                             " ")
                                                                         :cmdline))
                                       :nargs "*"})))

(fn [cmd]
  (fn [loader]))
