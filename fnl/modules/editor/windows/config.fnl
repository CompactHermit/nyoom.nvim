(import-macros {: custom-set-face! : packadd!} :macros)

((->> :setup (. (autoload :fidget))))

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn _folkeStp []
  "
  Folke Modules and Goodness
  "
  (packadd! folke_edgy)
  (packadd! folke_trouble)
  (packadd! folke_todo-comments)
  (let [fidget (require :fidget)
        _eprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :edgy}})
        _cprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :todo-comments}})
        _tprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :trouble}})
        _commOpts {:keywords {:REFACTOR {:icon "󰷦 "
                                         :color "#2563EB"
                                         :alt [:REF :REFCT :REFACT]}}}
        _edgyOpts {:left [{:title :NeoTree
                           :ft :neo-tree
                           :filter (fn [buf]
                                     (= (. (. vim.b buf) :neo_tree_source)
                                        :filesystem))}
                          {:title "GIT Status"
                           :ft :neo-tree
                           :filter (fn [buf]
                                     (= (. (. vim.b buf) :neo_tree_source)
                                        :git_status))
                           :open "Neotree position=right git_status"}
                          {:title "Buffer List"
                           :ft :neo-tree
                           :filter (fn [buf]
                                     (= (. (. vim.b buf) :neo_tree_source)
                                        :buffers))}
                          {:ft :lspsagaoutline
                           ;; from <cmd>lua print(vim.bo.filetype) <cr>, the bast*** keeps changing the names, fml
                           :title "LSP Outline"
                           :open "Lspsaga outline"
                           :size {:height 1}}
                          :open
                          "Neotree position=top buffers"
                          {:ft :diff :title " Diffs"}
                          {:ft :DiffviewFileHistory :title " Diffs"}
                          {:ft :DiffviewFiles :title " Diffs"}
                          {:title "  Tasks"
                           :ft :OverseerList
                           :open :OverseerToggle}
                          {:ft :dapui_breakpoints :title :BreakPoints}
                          {:ft :dapui_stacks :title :Stacks}
                          {:ft :dapui_watches :title :Watches}]
                   ;; all other Neotree windows
                   :bottom [{:filter (fn [buf win]
                                       (= (. (vim.api.nvim_win_get_config win)
                                             :relative)
                                          ""))
                             :ft :toggleterm
                             :size {:height 0.4}}
                            {:ft :dapui_console :title "Dap Console"}
                            {:ft :vimstartuptime :title "Startup Time"}
                            {:ft :Trouble
                             :title " Trouble"
                             :open (fn []
                                     (((. (require :trouble)) :toggle) {:mode :quickfix}))}
                            {:ft :OverseerPanelTask
                             :title " Task"
                             :open "OverseerQuickAction open"}
                            {:ft :dap-repl :title "Debug REPL"}
                            {:ft :help :size {:height 20}}
                            :Trouble
                            {:ft [:qf] :title :QuickFix}]
                   :right [{:ft :tsplayground :title (.. :TSPlayground "::")}
                           :dapui_scopes
                           :ClangdAST
                           {:ft :syntax.rust :title "Rust AST"}
                           :sagaoutline
                           :neotest-output-panel
                           :neotest-summary]
                   :animate {:enabled true :fps 120}
                   :keys {:<c-q> (fn [win] (win:hide))
                          :<c-w>+ (fn [win] (win:resize :height 2))
                          :<c-w>- (fn [win] (win:resize :height (- 2)))
                          :<c-w><lt> (fn [win] (win:resize :width (- 2)))
                          :<c-w>= (fn [win] (win.view.edgebar:equalize))
                          :<c-w>> (fn [win] (win:resize :width 2))
                          :Q (fn [win] (win.view.edgebar:close))
                          "[W" (fn [win] (win:prev {:focus true :pinned false}))
                          "[w" (fn [win] (win:prev {:focus true :visible true}))
                          "]W" (fn [win] (win:next {:focus true :pinned false}))
                          "]w" (fn [win] (win:next {:focus true :visible true}))
                          :q (fn [win] (win:close))}
                   :wo {:winbar true
                        :winfixwidth false
                        :winhighlight "WinBar:EdgyWinBar,Normal:EdgyNormal"
                        :signcolumn :yes}
                   :options {:left {:size 40}
                             :right {:size 45}
                             :bottom {:size 14}}}]
    (_eprogress:report {:message "Setting Up edgy"
                        :level vim.log.levels.ERROR
                        :progress 0})
    (custom-set-face! :EdgyWinBar [:bold :italic] {:fg "#180030"})
    ((->> :setup (. (require :edgy))) _edgyOpts)
    (_cprogress:report {:message "Setting Up TodoComments::"
                        :level vim.log.levels.ERROR
                        :progress 10})
    ((->> :setup (. (require :todo-comments))) _commOpts)
    (_tprogress:report {:message "Setting Up Trouble"
                        :level vim.log.levels.ERROR
                        :progress 10})
    ((->> :setup (. (require :trouble))))
    (_eprogress:report {:message "Setup Complete"
                        :title :Completed!
                        :progress 99})
    (_tprogress:report {:message "Setup Complete"
                        :title :Completed!
                        :progress 99})
    (_cprogress:report {:message "Setup Complete"
                        :title :Completed!
                        :progress 99})))

(vim.api.nvim_create_autocmd :BufReadPost
                             {:pattern "*" :callback #(_folkeStp) :once true})
