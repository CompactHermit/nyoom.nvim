(import-macros {: packadd!
                : nyoom-module-p!
                : map!
                : custom-set-face!
                : let!
                : autocmd!
                : augroup!} :macros)

;; ┌─────────────────────────┬
;; │ Treesitter Highlights:: │
;; └─────────────────────────┘

(custom-set-face! :Conceal [] {:fg "#3ddbd9" :bg :NONE})
(custom-set-face! :TSRainbowRed [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :TSRainbowYellow [] {:fg "#a8a8a8" :bg :NONE})
(custom-set-face! :TSRainbowBlue [] {:fg "#8d8d8d" :bg :NONE})
(custom-set-face! :TSRainbowOrange [] {:fg "#a2a9b0" :bg :NONE})
(custom-set-face! :TSRainbowGreen [] {:fg "#8f8b8b" :bg :NONE})
(custom-set-face! :TSRainbowViolet [] {:fg "#ada8a8" :bg :NONE})
(custom-set-face! :TSRainbowCyan [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :Macro-call [] {:fg "#ff7eb6" :bg :NONE})
(nyoom-module-p! nix
                 (do
                   (custom-set-face! "@lsp.mod.builtin.nix" []
                                     {:fg "#3ddbd9" :bg :NONE})
                   (custom-set-face! "@lsp.type.parameter.nix" []
                                     {:fg "#ec9df4" :bg :NONE})))

;; Set Octo == Markdown
(vim.treesitter.language.register :markdown :octo)

;; ┌─────────────────────────┬
;; │  Treesitter Setup:      │
;; └─────────────────────────┘

(local _tsOpts
       {:highlight {:enable true :use_languagetree true}
        :indent {:enable false}
        :refactor {:enable false
                   ; :navigation {:enable true
                   ;              :keymap {:goto_definition :gnd
                   ;                       :list_definitions :gnD
                   ;                       :list_definitions_toc :gO
                   ;                       :goto_next_usage :<a-*>
                   ;                       :goto_previous_usage "<a-#>"}}
                   :highlight_current_scope {:enable false}
                   :highlight_definitions {:enable false
                                           :clear_on_cursor_move true}
                   :smart_rename {:enable false
                                  :keymaps {:smart_rename :<space>rn}}}
        :query_linter {:enable false
                       :use_virtual_text true
                       :lint_events [:BufWrite :CursorHold]}
        :incremental_selection {:enable true
                                :keymaps {:init_selection :gn
                                          :node_incremental :gnn
                                          :scope_incremental :gnc
                                          :node_decremental :gnm}}
        :textobjects {:select {:enable true
                               :lookahead true
                               :keymaps {:af "@function.outer"
                                         :if "@function.inner"
                                         :ac "@class.outer"
                                         :ic "@class.inner"}}
                      :move {:enable true
                             :set_jumps true
                             ;; Whether to add to jumplist, IDK y u'd disable this
                             :goto_next_start {"]n" "@function.outer"
                                               "]]" "@class.outer"
                                               "]nif" "@function.inner"
                                               "]np" "@parameter.inner"
                                               "]nc" "@call.outer"
                                               "]nic" "@call.inner"}
                             :goto_next_end {"]N" "@function.outer"
                                             "][" "@class.outer"}
                             :goto_previous_start {"[n" "@function.outer"
                                                   "[[" "@class.outer"}
                             :goto_previous_end {"[N" "@function.outer"
                                                 "[]" "@class.outer"}}}})

;; fnlfmt: skip
(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :treesitter}})
      rainbox (autoload :rainbow-delimiters)]

  (progress:report {:message "Setting Up treesitter"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :nvim-treesitter.configs))) _tsOpts) 
  ((->> :setup (. (require :ts_context_commentstring))) {:enable_autocmd false});})
  (let! skip_ts_context_commentstring_module true)
  (progress:report {:message "Setup Complete"
                    :title :Completed!
                    :progress 100})
  (progress:finish))
