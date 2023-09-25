;; I'm In fucking love with this plugin, like holly shit, multicursors are for patzers, we smoking trees
(import-macros {: nyoom-module-p! : map!} :macros)

;; Custom labels go here
(local {: jump : treesitter_search} (require :flash))
(local lib (require :util.flash))
(local lsp-utils (require :util.lsp))


(local labels "sfnjklhodwembuyvrgtcxzSZFNJKLHODWEMBUYVRGTCXZ/?.,;#")

(setup :flash {:action nil
               :continue false
               :highlight {:backdrop true
                           :groups {:backdrop :FlashBackdrop
                                    :current :FlashCurrent
                                    :label :FlashLabel
                                    :match :FlashMatch}
                           :matches true
                           :priority 5000}
               :jump {:autojump true
                      :history true
                      :jumplist true
                      :nohlsearch true
                      :pos :start
                      :register true}
               :label {:after true
                       :before false
                       :current true
                       :distance true
                       :exclude ""
                       :format (fn [opts]
                                 [[opts.match.label opts.hl_group]])
                       :min_pattern_length 0
                       :rainbow {:enabled false :shade 9}
                       :reuse :all
                       :style :overlay
                       :uppercase true}
               : labels
               :modes {:char {:autohide true
                              :config (fn [opts]
                                        (set opts.autohide
                                             (and (: (vim.fn.mode true) :find :no)
                                                  (= vim.v.operator :y)))
                                        (set opts.jump_labels
                                             (and opts.jump_labels (= vim.v.count 0))))
                              :enabled true
                              :highlight {:backdrop true}
                              :jump {:register true}
                              :jump_labels true
                              :keys {"," "]s" 1 :f 2 :F 3 :t 4 :T ";" "[s"}
                              :label {:exclude :hjkliardc}
                              :search {:wrap false}}
                       :diagnostics {:highlight {:backdrop true}}
                                    :label {:current true}
                                    :search {:incremental true
                                             :multi_window true
                                             :wrap true}
                       :fuzzy {:search {:mode :fuzzy}}
                       :hover {:action (fn [Matched state]
                                         (vim.api.nvim_win_call Matched.win
                                                                (fn []
                                                                  (vim.api.nvim_win_set_cursor Matched.win
                                                                                               Matched.pos)
                                                                  (lsp-utils.hover (fn [err
                                                                                        result
                                                                                        ctx]
                                                                                     (vim.cmd "Lspsaga hover_doc")
                                                                                     (vim.api.nvim_win_set_cursor Matched.win
                                                                                                                  state.pos))))))
                                :search {:mode :fuzzy}}
                       :leap {:search {:max_length 2}}
                       :references {}
                       :remote {:jump {:autojump true} :search {:mode :fuzzy}}
                       :search {:enabled true
                                :highlight {:backdrop false}
                                :jump {:history true
                                       :nohlsearch true
                                       :register true}
                                :search {}}
                       :search_diagnostics {:action (lib.there_and_back lsp-utils.diag_line)
                                            :search {:mode :fuzzy}}
                       :select {:highlight {:label {:after true :before true}}
                                    :jump {:pos :range}
                                :search {:mode :fuzzy}}
                       :textcase {:search {:mode lib.mode_textcase}}
                       :treesitter {:highlight {:backdrop true :matches true}
                                    :jump {:pos :range}
                                    :label {:after true :before true :style :inline}
                                    : labels
                                    :search {:incremental false}}
                       :treesitter_search {:jump {:pos :range}
                                           :label {:after true
                                                   :before true
                                                   :style :inline}
                                           :remote_op {:restore true}
                                           :search {:incremental false
                                                    :multi_window true
                                                    :wrap true}}}
               :pattern ""
               :prompt {:enabled true
                        :prefix [["⚡" :FlashPromptIcon]]
                        :win_config {:col 0
                                     :height 1
                                     :relative :editor
                                     :row (- 1)
                                     :width 1
                                     :zindex 1000}}
               :remote_op {:motion true :restore false}
               :search {:forward true
                        :incremental true
                        :mode :exact
                        :multi_window true
                        :wrap true}})


; ╭────────────────────────────────────────────────────────────────────╮
; │         Remote Jumps  and treesitter bindings                      │
; ╰────────────────────────────────────────────────────────────────────╯
;; NOTE:: (CompactHermit) <09/04> Many of these are broken, because the `swap_with` api is broken, need to fix
(nyoom-module-p! tree-sitter
                 (do
                  (map! [n] :<leader>fea
                        `(treesitter_search {:label {:before true :after true :style :inline}
                                             :remote_op {:restore true}})
                        {:desc "TS::<Show Nodes>"})
                  (map! [n o x] :<leader>fet
                        `(jump {:mode ";remote_ts"})
                         {:desc "<BROKEN>"})
                  (map! [x o] "<leader>fen"
                        `(jump {:mode ";remote_ts" :treesitter {:starting_from_pos true}})
                        {:desc "Jump:: <Start Node(x)>"})
                  (map! [x o] :<leader>fee
                        `(jump {:mode ";remote_ts" :treesitter {:ending_at_pos true}})
                        {:desc "Select node(e)"})
                  (map! [n] :<leader>feW
                        `(jump {:mode :textcase :pattern (vim.fn.expand "<cWORD>")})
                        {:desc "Jump:: <textcase>"})
                  (map! [n x] :<leader>feX
                        `(lib.swap_with {:mode ";remote_ts"})
                        {:desc "Swaps"})
                  (map! [n x] :<leader>fex
                        `(lib.swap_with {})
                        {:desc "Exchange <motion1> with <node>"})
                  (map! [n] :<leader>fer
                        `(fn []
                           (vim.api.nvim_feedkeys ";r" "m" false)
                           (vim.schedule (fn []
                                           (jump {:mode ";remote_ts"}))))
                        {:desc "Remote Replace"})
                  (map! [n x] :<leader>fey
                        `(lib.swap_with {:exchange {:not_there true}})
                        {:desc "Replace with <remote-motion>"})
                  (map! [n x] :<leader>fed
                        `(lib.swap_with {:exchange {:not_there true}})
                        {:desc "Replace with d<remote-motion>"})
                  (map! [n x] :<leader>fec
                        `(lib.swap_with {:exchange {:not_there true}})
                        {:desc "Replace with c<remote-motion>"})))

