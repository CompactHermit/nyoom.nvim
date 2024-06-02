(import-macros {: packadd! : map! : nyoom-module-p! : autocmd!} :macros)

;(local {: executable?} (autoload :core.lib))

;; TODO:: Theres probably a better way to do this all with a macro import.
;; Since all we're doing is importing a table within a table, hmmmm.
;; Note:: The downside to this is an insane telescope load time. nearly 300ms+

(let [fidget (autoload :fidget)
      actions-layout (autoload :telescope.actions.layout)
      flash (fn [prompt_bufnr]
              ((->> :jump (. (require :flash))) {:action (fn [matched]
                                                           (local picker
                                                                  ((. (require :telescope.actions.state)
                                                                      :get_current_picker) prompt_bufnr))
                                                           (picker:set_selection (- (. matched.pos
                                                                                       1)
                                                                                    1)))
                                                 :label {:after [0 0]}
                                                 :pattern "^"
                                                 :search {:exclude [(fn [win]
                                                                      (not= (. (. vim.bo
                                                                                  (vim.api.nvim_win_get_buf win))
                                                                               :filetype)
                                                                            :TelescopeResults))]
                                                          :mode :search}}))
      state (autoload :telescope.state)
      actions (autoload :telescope.actions)
      action-set (autoload :telescope.actions.set)
      {: load_extension} (autoload :telescope)
      action-state (autoload :telescope.actions.state)
      {: close
       : file_edit
       : file_split
       : file_tab
       : file_vsplit
       : move_selection_next
       : move_selection_previous
       : open_qflist
       : preview_scrolling_down
       : preview_scrolling_up
       : select_default
       : select_vertical
       : send_selected_to_qflist
       : send_to_qflist} (require :telescope.actions)
      _multiopen (fn [prompt-bufnr open-cmd]
                   (let [picker (action-state.get_current_picker prompt-bufnr)
                         num-selections (table.getn (picker:get_multi_selection))
                         border-contents (. picker.prompt_border.contents 1)]
                     (when (not (or (string.find border-contents "Find Files")
                                    (string.find border-contents "Git Files")))
                       (select_default prompt-bufnr)
                       (lua "return "))
                     (if (> num-selections 1)
                         (do
                           (vim.cmd :bw!)
                           (each [_ entry (ipairs (picker:get_multi_selection))]
                             (vim.cmd (string.format "%s %s" open-cmd
                                                     entry.value)))
                           (vim.cmd :stopinsert))
                         (if (= open-cmd :vsplit) (file_vsplit prompt-bufnr)
                             (= open-cmd :split) (file_split prompt-bufnr)
                             (= open-cmd :tabe) (file_tab prompt-bufnr)
                             (file_edit prompt-bufnr)))))
      custom-actions {:multi_selection_open_tab (fn [prompt-bufnr]
                                                  (_multiopen prompt-bufnr
                                                              :split))}
      _mappings {:i {:<C-a> (+ send_to_qflist open_qflist)
                     :<C-d> :preview_scrolling_down
                     :<C-h> :which_key
                     :<c-j> :move_selection_next
                     :<C-k> :move_selection_previous
                     :<C-l> flash
                     :<C-n> (fn [prompt-bufnr]
                              (local results-win
                                     (. (state.get_status prompt-bufnr)
                                        :results_win))
                              (local height
                                     (vim.api.nvim_win_get_height results-win))
                              (action-set.shift_selection prompt-bufnr
                                                          (math.floor (/ height
                                                                         2))))
                     :<C-o> :select_vertical
                     :<C-p> (fn [prompt-bufnr]
                              (local results-win
                                     (. (state.get_status prompt-bufnr)
                                        :results_win))
                              (local height
                                     (vim.api.nvim_win_get_height results-win))
                              (action-set.shift_selection prompt-bufnr
                                                          (- (math.floor (/ height
                                                                            2)))))
                     :<C-q> (+ send_selected_to_qflist open_qflist)
                     :<C-u> :preview_scrolling_up
                     :<c-p> actions-layout.toggle_prompt_position
                     :<c-S> custom-actions.multi_selection_open_split
                     :<c-T> custom-actions.multi_selection_open_tab
                     :<C-V> custom-actions.multi_selection_open_vsplit
                     :<cr> custom-actions.multi_selection_open}
                 :n {:<C-Q> (+ send_selected_to_qflist open_qflist)
                     :<C-a> (+ send_to_qflist open_qflist)
                     :s flash
                     :<C-d> :preview_scrolling_down
                     :<C-h> :which_key
                     :<C-j> :move_selection_next
                     :<C-k> :move_selection_previous
                     ;;:<C-l> actions-layout.toggle_preview
                     :<C-o> :select_vertical
                     :<C-u> :preview_scrolling_up
                     :<c-S> custom-actions.multi_selection_open_split
                     :<c-t> custom-actions.multi_selection_open_tab
                     :<c-v> custom-actions.multi_selection_open_vsplit
                     :<cr> custom-actions.multi_selection_open
                     :q close}}
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :telescope}})
      _opts {:defaults {:prompt_prefix "   "
                        :selection_caret "  "
                        :entry_prefix "  "
                        :sorting_strategy :ascending
                        :layout_strategy :flex
                        :set_env {:COLORTERM :truecolor}
                        :dynamix_preview_title true
                        :layout_config {:horizontal {:prompt_position :top
                                                     :preview_width 0.55}
                                        :vertical {:mirror false}
                                        :width 0.87
                                        :height 0.8
                                        :preview_cutoff 120}
                        :mappings _mappings
                        :pickers {:oldfiles {:prompt_title "Recent files"}
                                  :help_tags {:theme :ivy}}}}]
  (progress:report {:message "Setting Up telescope"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :telescope))) _opts)
  ((->> :setup (. (require :telescope-tabs))))
  (load_extension :ui-select)
  (load_extension :file_browser)
  (load_extension :project)
  (load_extension :egrepify)
  (progress:report {:message "Setup Complete" :title :Completed! :progress 99})
  ((->> :setup (. (require :telescope))) _opts)
  (nyoom-module-p! default.+bindings
                   (do
                     (nyoom-module-p! lsp
                                      (do
                                        (local {:lsp_implementations open-impl-float!
                                                :lsp_references open-ref-float!
                                                :lsp_document_symbols open-local-symbol-float!
                                                :lsp_workspace_symbols open-workspace-symbol-float!}
                                               (require :telescope.builtin))
                                        (map! [n] :<leader>ci open-impl-float!
                                              {:desc "LSP Find implementations"})
                                        (map! [n] :<leader>cD open-ref-float!
                                              {:desc "LSP Jump to references"})
                                        (map! [n] :<leader>cj
                                              open-local-symbol-float!
                                              {:desc "LSP Jump to symbol in file"})
                                        (map! [n] :<leader>cJ
                                              open-workspace-symbol-float!
                                              {:desc "LSP Jump to symbol in workspace"})
                                        (map! [n] :<leader>*
                                              open-workspace-symbol-float!
                                              {:desc "LSP Symbols in project"})))
                     (nyoom-module-p! diagnostics
                                      (do
                                        (local {:diagnostics open-diag-float!}
                                               (require :telescope.builtin))
                                        (map! [n] :<leader>cx
                                              `(open-diag-float! {:bufnr 0})
                                              {:desc "Local diagnostics"})
                                        (map! [n] :<leader>cX open-diag-float!
                                              {:desc "Project diagnostics"})))))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))

; (nyoom-module-p! telescope.+native
;                  (do
;                    (packadd! telescope-fzf-native.nvim)
;                    (load_extension :fzf)))
