(fn swap_with_func [jump ma mb jumper]
  (let [reg (vim.fn.getreg "\"")
        (start finish) (values (vim.api.nvim_buf_get_mark 0 ma)
                               (vim.api.nvim_buf_get_mark 0 mb))
        (a b) (values (vim.api.nvim_buf_get_mark 0 :a)
                      (vim.api.nvim_buf_get_mark 0 :b))]
    (vim.api.nvim_buf_set_mark 0 :a (. start 1) (. start 2) {})
    (vim.api.nvim_buf_set_mark 0 :b (. finish 1) (. finish 2) {})
    (vim.api.nvim_feedkeys "`av`by" :nx false)
    (set _G.__remote_op_opfunc
         (fn []
           (var action "`[v`]")
           (if (and (and jump jump.exchange) jump.exchange.not_there)
               (set action (.. action :y))
               (set action (.. action :p)))
           (when (and (and jump jump.exchange) (not jump.exchange.not_here))
             (set action (.. action "`av`bp")))
           (vim.cmd (.. "normal! " action))
           (vim.fn.setreg "\"" reg)
           (vim.api.nvim_buf_set_mark 0 :a (. a 1) (. a 2) {})
           (vim.api.nvim_buf_set_mark 0 :b (. b 1) (. b 2) {})))
    (set vim.go.operatorfunc "v:lua.__remote_op_opfunc")
    (vim.api.nvim_feedkeys "g@" :n false)
    (if jumper (jumper jump)
        (vim.schedule (fn []
                        ((. (require :flash) :jump) (vim.tbl_deep_extend :force
                                                                         {:remote {:motion true
                                                                                   :restore true}}
                                                                         (or jump
                                                                             {}))))))))

(fn swap_with [opts]
  (set _G.__remote_op_opfunc (fn [] (swap_with opts "[" "]")))
  (set vim.go.operatorfunc "v:lua.__remote_op_opfunc")
  (vim.api.nvim_feedkeys "g@" :n false))

;; NOTE:: (CompactHermit) <9/04> this is very stupid, fix it.
(fn mode_textcase [pat modes]
  (set-forcibly! modes (or modes
                           [:to_constant_case
                            :to_lower_case
                            :to_snake_case
                            :to_dash_case
                            :to_camel_case
                            :to_pascal_case
                            :to_path_case
                            :to_title_case
                            :to_phrase_case
                            :to_dot_case]))
  (local pats [pat])
  (local tc (. (require :textcase) :api))
  (each [_ mode (ipairs modes)]
    (local pat2 ((. tc mode) pat))
    (when (not= pat2 pat)
      (tset pats (+ (length pats) 1) pat2)))
  (.. "\\V\\(" (table.concat pats "\\|") "\\)"))

(fn there_and_back [action jump-back]
  (fn [Matched state]
    (vim.api.nvim_win_call Matched.win
                           (fn []
                             (vim.api.nvim_win_set_cursor Matched.win
                                                          Matched.pos)
                             (action)
                             (vim.schedule (fn [] (state:restore)))))))

(fn get_nodes [win pos end_pos]
  (local nodes
         ((->> :get_nodes
               (. (require :flash.plugins.treesitter))) win pos)))

(fn remote_ts [win state opts]
  (when (= state.pattern.pattern " ")
    (set state.opts.search.max_length 1)
    (local matches
           ((->> :matcher
                 (. (require :flash.plugins.treesitter))) win state))
    (each [_ m (ipairs matches)] (set m.highlight false))
    (lua "return matches"))
  (local Search (require :flash.search))
  (local matches {})
  (local search (Search.new win state))
  (local smatches (search:get opts))
  (local find-nodes (> (length state.pattern.pattern) 1))
  (each [_ m (ipairs smatches)]
    ;; Oooga booga node traversal.
    ;; NOTE:: (CompactHermit) <09/04> I hate this, oh so much. @REWRITE! Macro-style!!
    (var n-nodes 0)
    (when find-nodes
      (each [_ n (ipairs (get_nodes win m.pos m.end_pos))]
        (var ok true)
        (when state.opts.treesitter.starting_from_pos
          (set ok (and ok (= m.pos n.pos))))
        (when state.opts.treesitter.ending_at_pos
          (set ok (and ok (= m.end_pos n.end_pos))))
        (when state.opts.treesitter.containing_end_pos
          (set ok (and ok (<= m.end_pos n.end_pos))))
        (when ok (set n-nodes 1) (set n.highlight false)
          (table.insert matches n))))
    (when (or (not find-nodes) (> n-nodes 0))
      (set m.label false)
      (table.insert matches m)))
  matches)

(fn set-highlight []
  "Sets the highlight for flash, using nyoom colors"
  (vim.api.nvim_set_hl 0 :FlashBackdrop {:link :Conceal})
  (vim.api.nvim_set_hl 0 :FlashLabel {:bg "#ff007c" :bold true :fg "#bdc9ff"}))

{: swap_with : there_and_back : mode_textcase : remote_ts}
