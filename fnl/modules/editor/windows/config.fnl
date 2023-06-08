;;TODO:: Somehow prettify LaSpaghet
(setup :edgy {:left [{:title "NeoTree"
                      :ft "neo-tree"
                      :filter (fn [buf]
                                (= (. (. vim.b buf) :neo_tree_source) "filesystem"))}
                     {:title "GIT Status"
                      :ft [:neo-tree]
                      :filter (fn [buf]
                                  (= (. (. vim.b buf) :neo_tree_source) "git_status"))
                      :pinned true
                      :open "Neotree position=right git_status"}
                     {:title "Buffer List"
                      :ft "neo-tree"
                      :filter (fn [buf]
                                (= (. (. vim.b buf) :neo_tree_source) "buffers"))
                      :pinned true
                      :open "Neotree position=top buffers"}
                     {:title "Overseer List"
                      :ft :OverseerList
                      :pinned true
                      :open :OverseerToggle}
                       ;; all other Neotree windows
                     :neo-tree]
              :bottom [{:filter (fn [buf win]
                                 (= (. (vim.api.nvim_win_get_config win) :relative)
                                    ""))
                        :ft :toggleterm
                        :size {:height 0.4}}
                       {:filter (fn [buf]
                                  (not (. (. vim.b buf) :lazyterm_cmd)))
                        :ft :lazyterm
                        :size {:height 0.4}
                        :title :LazyTerm}
                       :Trouble {:ft [:qf]
                                 :title :QuickFix}]
              :right [{:ft :lspsaga
                          :title "LSP Outline"
                          :open "Lspsaga outline"
                          :size {:height 0.5}}]
              :animate {:enabled true
                        :fps 120}})


