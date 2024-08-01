(comment "Uses nio to run system calls for tmux, effectively fzy searching panes based on <Name> and then resizing to the maximized values.
         equivelant to Zellij's `Sessionizer` which drops you into a resized environment")

;; Telescope is bloatware
(local pickers (autoload :telescope.pickers))
(local finders (autoload :telescope.finders))
(local config (. (autoload :telescope.config) :values))
(local sorter (. (autoload :telescope.sorters)))
(local actions (. (autoload :telescope.actions)))
(local actions_state (. (autoload :telescope.actions.state)))
(local fidget (autoload :fidget))
(local nio (require :nio))

;(fn switch-panes #(let [pane-names (nio)]))

(fn rename-pane [_paneID]
  "Nio.System -> Tmux::Select_pane()
    Renames a pane from the selected-window
    "
  (vim.ui.input {:prompt "[Re]name [P]ane::"}
                #(nio.fn.system (: "tmux select-pane -T %s -t %s" :format $1
                                   (- _paneID 1)))))

(lambda break-panes [?entry-choice]
  "")

(local switch-panes #(nio.fn.system (: "tmux select-pane -s" :format $1 $2)))

(local pane-rename (let [panes-names (nio.fn.system "tmux list-panes -F \"#{pane_index}.#{pane_title}\"")
                         tbl (-> (vim.iter (: panes-names :gmatch "(.-)\n"))
                                 (: :filter #(not= $1 ""))
                                 (: :fold {}
                                    #(let [num ((: $2 :gmatch "(%d).*"))]
                                       (tset $1 (+ (tonumber num) 1) $2)
                                       $1)))]
                     #(: (pickers.new {:prompt_title "[T]mux [P]ane [S]elect"
                                       :results_title "[P]anes"
                                       :preview_title "[P]ane [P]review"
                                       :finder (finders.new_table {:results tbl})
                                       :sorter (sorter.get_generic_fuzzy_sorter)
                                       :default_selection_index 1
                                       :attach_mappings #(do
                                                           (: actions.select_default
                                                              :replace
                                                              #(let [entry (actions_state.get_selected_entry)]
                                                                 ;(print (vim.inspect entry))
                                                                 (rename-pane entry.index)
                                                                 #(actions.close $1)))
                                                           #($2 :n :<M-L>
                                                                #(let [entry (actions_state.get_selected_entry)]
                                                                   (switch-panes)
                                                                   (actions.close $1))))})
                         :find)))

{: pane-rename}
