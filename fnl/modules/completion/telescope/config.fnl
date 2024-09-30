(import-macros {: custom-set-face! : map! : nyoom-module-p!} :macros)

; (custom-set-face! :TelescopeBorder [] {:fg oxocarbon.blend :bg oxocarbon.blend})
; (custom-set-face! :TelescopePromptBorder [] {:fg oxocarbon.base02 :bg oxocarbon.base02})
; (custom-set-face! :TelescopePromptNormal [] {:fg oxocarbon.base05 :bg oxocarbon.base02})
; (custom-set-face! :TelescopePromptPrefix [] {:fg oxocarbon.base08 :bg oxocarbon.base02})
; (custom-set-face! :TelescopeNormal [] {:fg oxocarbon.none :bg oxocarbon.blend})
; (custom-set-face! :TelescopePreviewTitle [] {:fg oxocarbon.base02 :bg oxocarbon.base12})
; (custom-set-face! :TelescopePromptTitle [] {:fg oxocarbon.base02 :bg oxocarbon.base11})
; (custom-set-face! :TelescopeResultsTitle [] {:fg oxocarbon.blend :bg oxocarbon.blend})
; (custom-set-face! :TelescopeSelection [] {:fg oxocarbon.none :bg oxocarbon.base02})
; (custom-set-face! :TelescopePreviewLine [] {:fg oxocarbon.none :bg oxocarbon.base01})
; (custom-set-face! :TelescopeMatching [:bold :italic] {:fg oxocarbon.base08 :bg oxocarbon.none})
;;TODO::(Hermit) <07/10> MACRO AWAY THIS JUNK

(local theme (. (autoload :util.color) :carbonfox))
(local tel-theme theme.telescope)
(local main tel-theme.main)
(local prompt tel-theme.prompt)
(local highlights {:TelescopeBorder {:bg theme.background :fg main}
                   :TelescopeMatching {:link :Special}
                   :TelescopeMultiIcon {:link :Identifier}
                   :TelescopeMultiSelection {:link :Type}
                   :TelescopeNormal {:bg main}
                   :TelescopePreviewBlock tel-theme.block
                   :TelescopePreviewCharDev tel-theme.charDev
                   :TelescopePreviewDate {:link :Directory}
                   :TelescopePreviewDirectory {:link :Directory}
                   :TelescopePreviewExecute {:link :String}
                   :TelescopePreviewGroup tel-theme.group
                   :TelescopePreviewHyphen {:link :NonText}
                   :TelescopePreviewLine {:link :Visual}
                   :TelescopePreviewLink {:link :Special}
                   :TelescopePreviewMatch {:link :Search}
                   :TelescopePreviewMessage {:link :TelescopePreviewNormal}
                   :TelescopePreviewMessageFillchar {:link :TelescopePreviewMessage}
                   :TelescopePreviewPipe tel-theme.pipe
                   :TelescopePreviewRead tel-theme.read
                   :TelescopePreviewSize {:link :String}
                   :TelescopePreviewSocket {:link :Statement}
                   :TelescopePreviewSticky {:link :Keyword}
                   :TelescopePreviewTitle {:link :TelescopeTitle}
                   :TelescopePreviewUser tel-theme.user
                   :TelescopePreviewWrite {:link :Statement}
                   :TelescopePromptBorder {:bg theme.background :fg prompt}
                   :TelescopePromptCounter {:link :NonText}
                   :TelescopePromptNormal {:bg prompt}
                   :TelescopePromptPrefix tel-theme.promptPrefix
                   :TelescopePromptTitle {:link :TelescopeTitle}
                   :TelescopeResultsClass {:link :Function}
                   :TelescopeResultsComment {:link :Comment}
                   :TelescopeResultsConstant tel-theme.constant
                   :TelescopeResultsDiffAdd {:link :DiffAdd}
                   :TelescopeResultsDiffChange {:link :DiffChange}
                   :TelescopeResultsDiffDelete {:link :DiffDelete}
                   :TelescopeResultsDiffUntracked {:link :NonText}
                   :TelescopeResultsField {:link :Function}
                   :TelescopeResultsFunction {:link :Function}
                   :TelescopeResultsIdentifier {:link :Identifier}
                   :TelescopeResultsLineNr {:link :LineNr}
                   :TelescopeResultsMethod {:link :Method}
                   :TelescopeResultsNumber tel-theme.number
                   :TelescopeResultsOperator {:link :Operator}
                   :TelescopeResultsSpecialComment {:link :SpecialComment}
                   :TelescopeResultsStruct {:link :Struct}
                   :TelescopeResultsTitle {:link :TelescopeTitle}
                   :TelescopeResultsVariable {:link :SpecialChar}
                   :TelescopeSelection {:link :Visual}
                   :TelescopeSelectionCaret {:link :TelescopeSelection}
                   :TelescopeTitle tel-theme.title})

(each [k v (pairs highlights)] (vim.api.nvim_set_hl 0 k v))

(let [fidget (autoload :fidget)
      actions-layout (autoload :telescope.actions.layout)
      flash (fn [prompt_bufnr]
              ((->> :jump (. (autoload :flash))) {:action (fn [matched]
                                                            (local picker
                                                                   ((. (autoload :telescope.actions.state)
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
                             (= open-cmd :tab) (file_tab prompt-bufnr)
                             (file_edit prompt-bufnr)))))
      custom-actions {:multi_selection_open_tab #(_multiopen $1 :tab)
                      :multi_selection_open_split #(_multiopen $1 :split)
                      :multi_selection_open_vsplit #(_multiopen $1 :vsplit)}
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
                     :<C-S> custom-actions.multi_selection_open_split
                     :<C-t> custom-actions.multi_selection_open_tab
                     :<c-v> custom-actions.multi_selection_open_vsplit
                     :<cr> custom-actions.multi_selection_open
                     :q close}}
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :telescope-plugins}})
      _opts {:extensions {:zf-native {:file {:enable true
                                             :highlight_results true}}}
             :defaults {:prompt_prefix "   "
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
  (progress:report {:message "Setting Up telescope-plugins"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :telescope))) _opts)
  ((->> :setup (. (require :telescope-tabs))))
  (load_extension :ui-select)
  (load_extension :file_browser)
  (load_extension :zf-native)
  (load_extension :project)
  (load_extension :zoxide)
  (load_extension :egrepify)
  (progress:report {:message "Setup Complete" :title :Completed! :progress 99})
  ;((->> :setup (. (require :telescope))) _opts)
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
