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

;; ┌─────────────────────────┬
;; │  Treesitter Autocmds::  │
;; └─────────────────────────┘

; (autocmd! :FileType "*" #(fn [ci]
;                            (vim.fn.schedule (fn []
;                                               (if (and (utils.active? (ci.buf)) (not= (: vim.opt_local.foldmethod :get) :diff))
;                                                   (print :hello)))))
;
;           {:group (vim.api.nvim_create_augroup :TSFolds {})})
(nyoom-module-p! nix
                 (do
                   (custom-set-face! "@lsp.mod.builtin.nix" []
                                     {:fg "#3ddbd9" :bg :NONE})
                   (custom-set-face! "@lsp.type.parameter.nix" []
                                     {:fg "#ec9df4" :bg :NONE})))

;; ┌─────────────────────────┬
;; │  Treesitter Setup:   :  │
;; └─────────────────────────┘

(local _tsOpts
       {;;:ensure_installed treesitter-filetypes
        :highlight {:enable true :use_languagetree true}
        :indent {:enable true}
        :refactor {:enable true
                   ; :navigation {:enable true
                   ;              :keymap {:goto_definition :gnd
                   ;                       :list_definitions :gnD
                   ;                       :list_definitions_toc :gO
                   ;                       :goto_next_usage :<a-*>
                   ;                       :goto_previous_usage "<a-#>"}}
                   :highlight_current_scope {:enable false}
                   :highlight_definitions {:enable true
                                           :clear_on_cursor_move true}
                   :smart_rename {:enable true
                                  :keymaps {:smart_rename :<localleader>rn}}}
        :query_linter {:enable true
                       :use_virtual_text true
                       :lint_events [:BufWrite :CursorHold]}
        :incremental_selection {:enable true
                                :keymaps {:init_selection :gn
                                          :node_incremental :gnn
                                          :scope_incremental :gnc
                                          :node_decremental :gnm}}
        :textobjects {:select {:enable true}
                      :lookahead true
                      :keymaps {:af "@function.outer"
                                :if "@function.inner"
                                :ac "@class.outer"
                                :ic "@class.inner"}
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
(fn __treesitterSetup []
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
  "
        Treesitter Module::
          This module uses the following extensions. We lazyload ev

        "
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :treesitter}})
        rainbox (autoload :rainbow-delimiters)]
    (packadd! tsplayground)
    ;(packadd! rainbow-delimiters)
    ;(packadd! ts-context)
    (packadd! ts-context-commentstring)
    (packadd! ts-refactor)
    (packadd! ts-textobjects)
    (packadd! ts-node-action)
    (progress:report {:message "Setting Up treesitter"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ;((->> :setup (. (require :treesitter-context))) {:enable true})
    ((->> :setup (. (require :nvim-treesitter.configs))) _tsOpts) 
    ((->> :setup (. (require :ts_context_commentstring))) {:enable_autocmd false});})
    (let! skip_ts_context_commentstring_module true)
    ; (let! rainbow_delimiters {:strategy {}
    ;                           :query {}
    ;                           :priority {}
    ;                           :highlight {}})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd [:BufRead]
                             {:group (vim.api.nvim_create_augroup :ts.setup
                                                                  {:clear true})
                              :callback (fn []
                                          (when (fn []
                                                  (local file
                                                         (vim.fn.expand "%"))
                                                  (and (not= file :nvimTree_1)
                                                       (not= file :HermitPack)
                                                       (not= file "")))
                                            ;(vim.api.nvim_del_augroup_by_name :ts.setup)
                                            (__treesitterSetup)))
                              :once true})

(fn loader []
  (vim.api.nvim_exec_autocmds :BufRead {:pattern :ts.setup}))

;; fnlfmt: skip
(let [commands [:TSBufToggle
                :TSModuleInfo]]
  (each [_ cmd (ipairs commands)]
    (vim.api.nvim_create_user_command cmd
                                      (fn [args]
                                        (vim.api.nvim_del_user_command cmd)
                                        (loader)
                                        (vim.cmd (string.format "%s %s%s%s %s"
                                                                (or args.mods
                                                                    "")
                                                                (or (and (= args.line1
                                                                            args.line2)
                                                                         "")
                                                                    (.. args.line1
                                                                        ","
                                                                        args.line2))
                                                                cmd
                                                                (or (and args.bang
                                                                         "!")
                                                                    "")
                                                                args.args)))
                                      {:bang true
                                       :complete (fn []
                                                   (vim.api.nvim_del_user_command cmd)
                                                   (loader)
                                                   (vim.fn.getcompletion (.. cmd
                                                                             " ")
                                                                         :cmdline))
                                       :nargs "*"})))
