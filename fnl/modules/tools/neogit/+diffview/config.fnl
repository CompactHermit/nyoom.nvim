(import-macros {: packadd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :diffview}})
      actions (autoload :diffview.actions)]
   (progress:report {:message "Setting Up diffview"
                     :level vim.log.levels.ERROR
                     :progress 0})
   ((->> :setup (. (require :diffview))) {:diff_binaries false
                                          :enhanced_diff_hl true
                                          :git_cmd [:git]
                                          :use_icons true
                                          :icons {:folder_closed ""
                                                  :folder_open ""}
                                          :signs {:fold_closed ""
                                                  :fold_open ""}
                                          :view {:merge_tool {:layout :diff3_mixed
                                                              :disable_diagnostics true}}
                                          :file_panel {:listing_style :tree
                                                       :tree_options {:flatten_dirs true
                                                                      :folder_statuses :only_folded}
                                                       :win_config {:position :left
                                                                    :width 35}}
                                          :file_history_panel {:log_options {:git {:single_file {:diff_merges :combined}
                                                                                   :multi_file {:diff_merges :first-parent}}}
                                                               :win_config {:position :bottom
                                                                            :height 16}}
                                          :commit_log_panel {:win_config {}}
                                          :default_args {:DiffviewOpen {}
                                                         :DiffviewFileHistory {}}
                                          :keymaps {:view {:gf actions.goto_file_edit
                                                           :- actions.toggle_stage_entry}
                                                    :file_panel {:<cr> actions.focus_entry
                                                                 :s actions.toggle_stage_entry
                                                                 :gf actions.goto_file_edit
                                                                 :? "<Cmd>h diffview-maps-file-panel<CR>"}
                                                    :file_history_panel {:<cr> actions.focus_entry
                                                                         :gf actions.goto_file_edit
                                                                         :? "<Cmd>h diffview-maps-file-history-panel<CR>"}}})
   (progress:report {:message "Setup Complete"
                     :title :Completed!
                     :progress 100}))

