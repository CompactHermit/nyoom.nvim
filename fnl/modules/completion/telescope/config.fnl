(import-macros {: packadd! : map! : nyoom-module-p! : augroup! : clear! : autocmd!} :macros)
(local {: load_extension} (autoload :telescope))
(local {: executable?} (autoload :core.lib))

;; TODO:: Theres probably a better way to do this all with a macro import.
;; Since all we're doing is importing a table within a table, hmmmm.
;; Note:: The downside to this is an insane telescope load time. nearly 300ms+
(local {: move_selection_next
        : move_selection_previous
        : select_vertical
        : select_default
        : send_to_qflist
        : send_selected_to_qflist
        : open_qflist
        : send_to_qflist
        : file_tab
        : file_vsplit
        : file_split
        : file_edit
        : preview_scrolling_up
        : preview_scrolling_down
        : close}
       (autoload :telescope.actions))
(local actions-layout (require :telescope.actions.layout))
(local state (require :telescope.state))
(local action-set (require :telescope.actions.set))
(local action-state (require :telescope.actions.state))

(local _multiopen
        (fn [prompt-bufnr open-cmd]
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
                    (vim.cmd (string.format "%s %s" open-cmd entry.value)))
                  (vim.cmd :stopinsert))
                (if (= open-cmd :vsplit) (file_vsplit prompt-bufnr)
                    (= open-cmd :split) (file_split prompt-bufnr)
                    (= open-cmd :tabe) (file_tab prompt-bufnr)
                    (file_edit prompt-bufnr))))))


;; Custom Functions::
(local custom-actions {:multi_selection_open_tab (fn [prompt-bufnr]
                                                  (_multiopen prompt-bufnr :tabe))
                       :multi_selection_open (fn [prompt-bufnr]
                                                (_multiopen prompt-bufnr :edit))
                       :multi_selection_open_vsplit (fn [prompt-bufnr]
                                                     (_multiopen prompt-bufnr :vsplit))
                       :multi_selection_open_split (fn [prompt-bufnr]
                                                     (_multiopen prompt-bufnr :split))})


(local _mappings {:i {:<C-a> (+ send_to_qflist open_qflist)
                      :<C-d> :preview_scrolling_down
                      :<C-h> :which_key
                      :<c-j> :move_selection_next
                      :<C-k> :move_selection_previous
                      :<C-l> actions-layout.toggle_preview
                      :<C-n> (fn [prompt-bufnr]
                               (local results-win
                                      (. (state.get_status prompt-bufnr) :results_win))
                               (local height (vim.api.nvim_win_get_height results-win))
                               (action-set.shift_selection prompt-bufnr
                                                           (math.floor (/ height 2))))
                      :<C-o> :select_vertical
                      :<C-p> (fn [prompt-bufnr]
                               (local results-win
                                      (. (state.get_status prompt-bufnr) :results_win))
                               (local height (vim.api.nvim_win_get_height results-win))
                               (action-set.shift_selection prompt-bufnr
                                                           (- (math.floor (/ height 2)))))
                      :<C-q> (+ send_selected_to_qflist open_qflist)
                      :<C-u> :preview_scrolling_up
                      :<c-p> actions-layout.toggle_prompt_position}
                  :n {:<C-Q> (+ send_selected_to_qflist open_qflist)
                      :<C-a> (+ send_to_qflist open_qflist)
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
                      :q close}})

;; TODO:: Sanitize this, making mappings it's own list, this is just stupid to configure
(setup :telescope {:defaults {:prompt_prefix "   "
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
                               ;; TODO:: add custom pickers for Telescope Browser/ Buffers/ Tabs, e.g: deletion and such
                              :pickers {:oldfiles {:prompt_title "Recent files"}}}})




;; Load extensions
(packadd! telescope-ui-select.nvim)
(load_extension :ui-select)
(packadd! telescope-file-browser.nvim)
(load_extension :file_browser)
(packadd! telescope-tmux.nvim)
(packadd! telescope-project.nvim)
(load_extension :project)
(packadd! telescope-session.nvim)
(load_extension :xray23)
(packadd! telescope-tabs)
(setup :telescope-tabs)
(packadd! telescope-egrepify.nvim)
(load_extension :egrepify)
(nyoom-module-p! debugger
    (packadd! telescope-dap.nvim)
    (load_extension :dap))
;; only install native if the flag is there

;; TODO:: Remove this for Nix, errors bcs they build fzf, which nix fails to find on rtp
(nyoom-module-p! telescope.+native
                 (do
                   (packadd! telescope-fzf-native.nvim)
                   (load_extension :fzf)))


;; load media-files and zoxide only if their executables exist
(when (executable? :ueberzug)
  (packadd! telescope-media-files.nvim)
  (load_extension :media_files))

(when (executable? :zoxide)
  (packadd! telescope-zoxide)
  (load_extension :zoxide))

(nyoom-module-p! default.+bindings
                 (do
                   (nyoom-module-p! lsp
                                    (do
                                      (local {:lsp_implementations open-impl-float!
                                              :lsp_references open-ref-float!
                                              :lsp_document_symbols open-local-symbol-float!
                                              :lsp_workspace_symbols open-workspace-symbol-float!}
                                             (autoload :telescope.builtin))
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
                                             (autoload :telescope.builtin))
                                      (map! [n] :<leader>cx
                                            `(open-diag-float! {:bufnr 0})
                                            {:desc "Local diagnostics"})
                                      (map! [n] :<leader>cX open-diag-float!
                                            {:desc "Project diagnostics"})))))


; local colors = require("current_color_Scheme").get_palete()
; local TelescopeColor = {
;                         	TelescopeMatching = { fg = colors.flamingo },
;                         	TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
;
;                         	TelescopePromptPrefix = { bg = colors.surface0 },
;                         	TelescopePromptNormal = { bg = colors.surface0 },
;                         	TelescopeResultsNormal = { bg = colors.mantle },
;                         	TelescopePreviewNormal = { bg = colors.mantle },
;                         	TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
;                         	TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
;                         	TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
;                         	TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
;                         	TelescopeResultsTitle = { fg = colors.mantle },
;                         	TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },}
;
;
; for hl, col in pairs(TelescopeColor) do
;   	vim.api.nvim_set_hl(0, hl, col)
; end
;
