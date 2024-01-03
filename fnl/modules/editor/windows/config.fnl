(import-macros {: custom-set-face!} :macros)
;;TODO:: Somehow prettify LaSpaghet
        ;; NVM:: Spaghett (tm) is unavoidable
(setup :edgy {:left [{:title "NeoTree"
                      :ft "neo-tree"
                      :filter (fn [buf]
                                (= (. (. vim.b buf) :neo_tree_source) "filesystem"))}
                     {:title "GIT Status"
                      :ft :neo-tree
                      :filter (fn [buf]
                                  (= (. (. vim.b buf) :neo_tree_source) "git_status"))
                      :open "Neotree position=right git_status"}
                     {:title "Buffer List"
                      :ft "neo-tree"
                      :filter (fn [buf]
                                (= (. (. vim.b buf) :neo_tree_source) "buffers"))}
                     {:ft :lspsagaoutline ;; from <cmd>lua print(vim.bo.filetype) <cr>, the bast*** keeps changing the names, fml
                      :title "LSP Outline"
                      :open "Lspsaga outline"
                      :size {:height 1.0}}
                     :open "Neotree position=top buffers"
                     {:title "Overseer List"
                      :ft :OverseerList
                      :open :OverseerToggle}
                     :dapui_breakpoints
                     :dapui_stacks
                     :dapui_watches]
                    ;; all other Neotree windows
              :bottom [{:filter (fn [buf win]
                                 (= (. (vim.api.nvim_win_get_config win) :relative)
                                    ""))
                        :ft :toggleterm
                        :size {:height 0.4}}
                       :dapui_console
                       :dap-repl
                       {:ft :help
                        :size {:height 20}}
                       :Trouble
                       {:ft [:qf]
                        :title :QuickFix}]
              :right [{:ft :tsplayground
                       :title (.. :TSPlayground "::")}
                      :dapui_scopes
                      :neotest-output-panel
                      :neotest-summary]
              :animate {:enabled true
                        :fps 120}
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
                   :signcolumn "yes"}
              :options {:left {:size 40}
                        :right {:size 30}
                        :bottom {:size 5}}})

(custom-set-face! :EdgyWinBar [:bold :italic] {:fg "#180030"})
; ```fennel
;   (custom-set-face! Error [:bold] {:fg \"#ff0000\"})
;   ```
;   That compiles to:
;   ```fennel
;   (vim.api.nvim_set_hl 0 \"Error\" {:fg \"#ff0000\"
;                                     :bold true})
