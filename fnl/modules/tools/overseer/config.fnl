(local STATUS (. (require :overseer.constants) :STATUS))

(setup :overseer {:actions {"don't dispose" {:desc "keep the task until manually disposed"
                                             :run (fn [task]
                                                    (task:remove_components [:on_complete_dispose]))}
                            "keep runnning" {:desc "restart the task even if it succeeds"
                                             :run (fn [task]
                                                    (task:add_components [{1 :on_complete_restart
                                                                           :statuses [STATUS.FAILURE
                                                                                      STATUS.SUCCESS]}])
                                                    (when (or (= task.status
                                                                 STATUS.FAILURE)
                                                              (= task.status
                                                                 STATUS.SUCCESS))
                                                      (task:restart)))}}
                  :auto_detect_success_color true
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
                  ;; TODO:: Make Hydra
                  :task_list {:bindings {:<C-e> :Edit
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
                                         "}" :NextTask}}
                  :templates [:builtin :users]})


