(import-macros {: custom-set-face! : set!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds

(let [fidget (require :fidget)
      _eprogress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :edgy}})
      _edgyOpts {:left [{:title :NeoTree
                         :ft :neo-tree
                         :filter (fn [buf]
                                   (= (. (. vim.b buf) :neo_tree_source)
                                      :filesystem))}
                        {:title :TOC
                         :ft :norg
                         :filter (fn [buf]
                                   (match (vim.api.nvim_buf_get_name buf)
                                     (where k1 (= k1 "neorg://toc-1")) true
                                     _ false))}
                        ;{:title "Neorg TOC"}
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
                 :bottom [{:filter (fn [buf win]
                                     (= (. (vim.api.nvim_win_get_config win)
                                           :relative)
                                        ""))
                           :ft :toggleterm
                           :size {:height 0.4}}
                          {:ft :dapui_console :title "Dap Console"}
                          {:ft :vimstartuptime :title "Startup Time"}
                          {:ft :neotest-output-panel
                           :title " Test Output"
                           :open (fn []
                                   (vim.cmd.vsplit)
                                   ((->> :toggle
                                         (. (autoload :neotest) :output_panel))))}
                          {:ft :trouble
                           :title " Trouble"
                           :open (fn []
                                   (((. (require :trouble)) :toggle) {:mode :quickfix}))}
                          {:ft :OverseerPanelTask
                           :title " Task"
                           :open "OverseerQuickAction open"}
                          ; {:ft :NoiceHistory
                          ;  :title " Log"
                          ;  :open #(__toggle_noice)}
                          {:ft :dap-repl :title "Debug REPL"}
                          {:ft :help :size {:height 20}}
                          ; {:ft :text :filter (fn [buf]
                          ;                      (buf.name ) :size {:height 20})}
                          {:ft :qf :title :QuickFix}]
                 :right [{:ft :tsplayground :title (.. :TSPlayground "::")}
                         :dapui_scopes
                         :ClangdAST
                         {:ft :syntax.rust :title "Rust AST"}
                         :sagaoutline
                         :neotest-output-panel
                         :neotest-summary]
                 :animate {:enabled true
                           :fps 100
                           :on_begin #(set! cmdheight 0)}
                 :exit_when_last true
                 :keys {:W (fn [win]
                             (let [Hydra (autoload :hydra)
                                   hint "
^^ _l_: increase width ^^
^^ _h_: decrease width ^^

^^ _L_: next open window ^^
^^ _H_: prev open window ^^

^^ _j_: next loaded window ^^
^^ _k_: prev loaded window ^^

^^ _J_: increase height ^^
^^ _K_: decrease height ^^
^^ _=_: reset all custom sizing ^^

^^ _<M-q>_: hide  ^^
^^ _q_: quit  ^^
^^ _Q_: close ^^

^^ _<esc>_: quit Hydra ^^

                                      "
                                   hk (Hydra {:name :Edgy
                                              :mode :n
                                              : hint
                                              :config {:color :pink
                                                       :hint {:type :window
                                                              :float_opts {:style :minimal
                                                                           :noautocmd true}
                                                              :position :bottom-right
                                                              :show_name true}
                                                       :invoke_on_body true}
                                              :heads [[:<M-q>
                                                       (fn [] (win:hide))
                                                       {:exit false}]
                                                      [:Q
                                                       (fn []
                                                         (win.view.edgebar:close))
                                                       {:exit true}]
                                                      [:<esc>
                                                       nil
                                                       {:desc :quit :exit true}]
                                                      [:q
                                                       (fn [] (win:close))
                                                       {:exit true}]
                                                      [:L
                                                       (fn []
                                                         (win:next {:focus true
                                                                    :visible true}))]
                                                      [:H
                                                       (fn []
                                                         (win:prev {:focus true
                                                                    :visible true}))]
                                                      [:j
                                                       (fn []
                                                         (win:next {:focus true
                                                                    :pinned false}))]
                                                      [:k
                                                       (fn []
                                                         (win:prev {:focus true
                                                                    :pinned false}))]
                                                      [:l
                                                       #(: win :resize :width 2)]
                                                      [:h
                                                       (fn []
                                                         (win:resize :width
                                                                     (- 2)))]
                                                      [:J
                                                       (fn []
                                                         (win:resize :height 2))]
                                                      [:K
                                                       (fn []
                                                         (win:resize :height
                                                                     (- 2)))]
                                                      ["="
                                                       (fn []
                                                         (win.view.edgebar:equalize))
                                                       {:desc :equalize
                                                        :exit true}]]})]
                               (hk:activate)))
                        :q (fn [win] (win:close))}
                 :wo {:winbar true
                      :winfixwidth false
                      :winfixheight false
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
  (_eprogress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 100})
  (_eprogress:finish))
