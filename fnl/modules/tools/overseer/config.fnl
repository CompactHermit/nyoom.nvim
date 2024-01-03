(local {: close-task} (require :util.overseer))
(local Border [ "🭽" "▔" "🭾" "▕" "🭿" "▁" "🭼" "▏"])

;; (local util (require :overseer.util))
;; (local STATUS (. (require :overseer.constants) :STATUS))
;;
;; (setup :overseer ;;;; Setup custom actions
;;        {:actions {"don't dispose" {:desc "keep the task until manually disposed"
;;                                    :run (fn [task]
;;                                           (task:remove_components [:on_complete_dispose]))}
;;                   "dump task" {:desc "save task table to DumpTask (for debugging)"
;;                                :run (fn [task]
;;                                       (local DumpTask task))}
;;                   "keep runnning" {:desc "restart the task even if it succeeds"
;;                                    :run (fn [task]
;;                                           (task:add_components [{1 :on_complete_restart
;;                                                                  :statuses [STATUS.FAILURE
;;                                                                             STATUS.SUCCESS]}])
;;                                           (when (or (= task.status
;;                                                        STATUS.FAILURE)
;;                                                     (= task.status
;;                                                        STATUS.SUCCESS))
;;                                             (task:restart)))}
;;                   :unwatch {:desc "stop from running on finish or file watch"
;;                             :run (fn [task]
;;                                    (each [_ component (pairs [:on_complete_restart
;;                                                               :on_complete_restart])]
;;                                      (when (task:has_component component)
;;                                        (task:remove_components [component]))))
;;                             :condition (fn [task]
;;                                          (or (task:has_component :on_complete_restart))
;;                                          (task:has_component :restart_on_save))}
;;                   "open here" {:desc "open as bottom panel"
;;                                :run (fn [task]
;;                                       (tset (. vim.bo task.strategy.bufnr)
;;                                             :filetype :OverseerTask)
;;                                       (vim.api.nvim_win_set_buf 0
;;                                                                 (task:get_bufnr))
;;                                       (set vim.wo.statuscolumn "%s")
;;                                       (util.scroll_to_end 0))
;;                                :condition (fn [task]
;;                                             (let [bufnr (task:get_bufnr)]
;;                                               (and bufnr
;;                                                    (vim.api.nvim_buf_is_valid bufnr))))}
;;                   "set as reciever" {:desc "Sets tasks as terminal to recieve commands"
;;                                      :run (fn [task]
;;                                             (local SendID task.strategy.chan_id))}
;;                   :open {:desc "Open As bottom Panel"
;;                          :run (fn [task] (vim.notify "Runner: opening task")
;;                                 (vim.cmd "normal! m'")
;;                                 (close-task task.strategy.bufnr)
;;                                 (tset (. vim.bo task.strategy.bufnr) :filetype
;;                                       :OverseerPanelTask)
;;                                 (vim.cmd.vsplit)
;;                                 (vim.api.nvim_win_set_buf 0 (task:get_bufnr))
;;                                 (util.scroll_to_end 0))
;;                          :condition (fn [task] (local bufnr (task:get_bufnr))
;;                                       (and bufnr
;;                                            (vim.api.nvim_buf_is_valid bufnr)))}}
;;         :auto_detect_success_color true
;;         ;;:confirm {:border Border :win_opts {:winblend 0}}
;;         :component_aliases {:always_restart {1 :on_complete_restart
;;                                              :statuses [STATUS.FAILURE
;;                                                         STATUS.SUCCESS]}
;;                             :default [:on_output_summarize
;;                                       :on_exit_set_status
;;                                       {1 :on_complete_notify
;;                                        :system :unfocused}
;;                                       :on_complete_dispose
;;                                       :display_duration]
;;                             :default_neotest [:on_output_summarize
;;                                               :on_exit_set_status
;;                                               [:on_complete_notify]
;;                                               :on_complete_dispose
;;                                               :unique
;;                                               :display_duration]}
;;         :dap true
;;         ;;:form {:border Border :win_opts {:winblend 0}}
;;         :strategy :terminal
;;         ;;:task_editor {:border Border :win_opts {:winblend 0}}
;;         ;;:task_win {:border Border :win_opts {:winblend 0}}
;;         :task_list {:separator "───────────────────────────────────────────────────────────────────────────────"
;;                     :bindings {:<C-e> :Edit
;;                                :<C-f> :OpenFloat
;;                                :<C-s> :OpenSplit
;;                                :<C-v> :OpenVsplit
;;                                :<CR> :RunAction
;;                                :? :ShowHelp
;;                                :H :DecreaseAllDetail
;;                                :L :IncreaseAllDetail
;;                                :O :Open
;;                                "[" :DecreaseWidth
;;                                "]" :IncreaseWidth
;;                                :h :DecreaseDetail
;;                                :l :IncreaseDetail
;;                                :p :TogglePreview
;;                                "{" :PrevTask
;;                                "}" :NextTask}
;;                     :direction :left
;;                     :min_height 20
;;                     :height (math.floor (* vim.o.lines 0.3))
;;                     :max_height 40}
;;         :templates [:cargo
;;                     :just
;;                     :make
;;                     :npm
;;                     :shell
;;                     :tox
;;                     :vscode
;;                     :mix
;;                     :rake
;;                     :task
;;                     :user]})

(setup :overseer {:dap true
                  :form {:border Border :win_opts {:winblend 0}}
                  :task_list {:separator "────────────────────────────────────────────────────────────────────────────────"}
                  :templates [:cargo
                              :just
                              :make
                              :npm
                              :shell
                              :tox
                              :vscode
                              :mix
                              :rake
                              :task
                              :user]})
