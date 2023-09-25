;; TODO:: Move these over to utility folder

;; NOTE: it would just be better to create a hydra-utils file, IMO
(local default-terminal 1)
(local input-prompt "enter the command: cmd >")
(local terminal-prompt "Enter a terminal Number ")
;; Tmux/Harpoon Util functions
(local cache {:command "ls -a" :tmux {:selected_plane ""}})
(local use_tmux_or_normal {:harpoon {:goto_harpoon false :use_tmux_or_normal :tmux}})


;; defines container for tmux
(fn plane []
  (let [data (vim.fn.system "tmux list-panes")
        lines (vim.split data "\n")
        container {}]
    (each [_ line (ipairs lines)]
      (local (output output-2) (line:match "^(%d+):.*(%%%d+)"))
      (when (and (and (not= output nil) (not= output-2 nil)) (not= output :1))
        (table.insert container (.. output " : " output-2))))
    (local unicode ["Σ" "Φ" "Ψ" "λ" "Ω"])
    (each [i symbol (ipairs unicode)]
      (table.insert container (.. symbol " : " i)))
    container))

(fn tmux-goto [term]
  (if (and (not= (vim.fn.getenv :TMUX) vim.NIL) use_tmux_or_normal)
      ((->> :gotoTerminal
           (. (require :harpoon.tmux))) term)
      ((->>
         (. (require :harpoon.term) :gotoTerminal)) term)))

(fn terminal-send [term cmd]
  (var module nil)
  (local goto-func :gotoTerminal)
  (if (not= (vim.fn.getenv :TMUX) vim.NIL)
      (do
        (set module (or (and (string.find term "%%") :harpoon.tmux)
                        :harpoon.tmux))
        (when (not (string.find term "%%"))
          (set-forcibly! term (tonumber term))))
      (set module :harpoon.term))
  ((. (require module) :sendCommand) term cmd)
  (when (= use_tmux_or_normal.goto_harpoon true)
    (vim.defer_fn (fn []
                    ((. (require module) goto-func) term))
      (or (and (string.find module :tmux) 500) 1000))))

(fn handle-tmux []
  (let [data (plane)]
    (var selected-plane cache.tmux.selected_plane)
    (when (= selected-plane "")
      (local filtered (vim.tbl_filter (fn [item] (string.find item "%%")) data))
      (set selected-plane
           (or (and (> (length filtered) 0)
                    (. (vim.split (. filtered 1) " : ") 2))
               (. (vim.split (. data 1) " : ") 2))))
    (set cache.tmux.selected_plane selected-plane)
    (table.insert data (.. "0: cache : " selected-plane))
    (table.sort data (fn [a b] (< (a:lower) (b:lower))))
    (vim.ui.select data {:prompt "Select a Plane "}
                   (fn [selected-item]
                     (let [selected-plane (or (and (= selected-item :cache)
                                                   cache.tmux.selected_plane)
                                              (. (vim.split selected-item " : ")
                                                 2))]
                       (set cache.tmux.selected_plane
                            (or (and (string.find selected-plane "%%")
                                     selected-plane)
                                (tonumber selected-plane)))
                       (set cache.command
                            (or (and (string.find cache.command "%D")
                                     cache.command)
                                (tonumber cache.command)))
                       (terminal-send cache.tmux.selected_plane cache.command))))))

(fn handle-non-tmux []
  (vim.ui.input {:default default-terminal :prompt terminal-prompt}
                (fn [terminal-number]
                  (when (not (string.find terminal-number "%D"))
                    (local term (tonumber terminal-number))
                    (terminal-send term cache.command)))))

(fn handle-command-input [command]
  (set cache.command (or (and (not= command "") command) cache.command))
  (handle-tmux))



;;===============================================================;;
;;Octo-puss;;;;;;;;;;
(local choice_edge_case {:all  ""})
(local defaults {:repo :CompactHermit
                 :pr :all
                 :issue :all
                 :label :Bug
                 :gist :all})


;; TODO:: restructure with actual macros, you slow fuck

(fn lambda-match [value compare]
  (fn [statements]
    (when (= value nil) (lua "return "))
    (set-forcibly! compare (or compare
                               (fn [lhs rhs]
                                 (when (= (type lhs) :boolean)
                                   (let [___antifnl_rtn_1___ (= (tostring lhs)
                                                                rhs)]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (= lhs rhs))))
    (each [___case___ action (pairs statements)]
      (when (and (= (type ___case___) :table) (vim.tbl_islist ___case___))
        (each [_ subcase (ipairs ___case___)]
          (when (compare value subcase)
            (when (= (type action) :function)
              (let [___antifnl_rtns_1___ [(action value)]]
                (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
            (lua "return action"))))
      (when (compare value ___case___)
        (when (= (type action) :function)
          (let [___antifnl_rtns_1___ [(action value)]]
            (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
        (lua "return action")))
    (when statements._
      (local action statements._)
      (when (= (type action) :function)
        (let [___antifnl_rtns_1___ [(action value)]]
          (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
      action)))




;; TODO: add this to core.utils, as this is pretty fking useful
(fn lambda-when [comparison when-true when-false]
  (when (not= (type comparison) :boolean)
    (set-forcibly! comparison (not= comparison nil)))
  ((lambda-match (or (and (= (type comparison) :table)
                          (unpack comparison))
                     comparison)) {:false when-false :true when-true}))

(fn caller [options ch]
  (vim.ui.select options {:format_item (fn [item] (.. "Octo " ch " " item))
                          :prompt "Select a choice"}
                 (fn [choice]
                   (lambda-when (vim.tbl_contains [:issue
                                                   :gist
                                                   :pr
                                                   :repo
                                                   :search
                                                   :label]
                                                 ch)
                               (fn []
                                 (lambda-when (vim.tbl_contains [:search
                                                                 :list
                                                                 :edit
                                                                 :create
                                                                 :resolve
                                                                 :unresolve
                                                                 :add
                                                                 :remove
                                                                 :create]
                                                                choice)
                                             (fn []
                                               (vim.ui.input {:default (. defaults
                                                                          ch)
                                                              :prompt (.. "Enter a option for "
                                                                          ch
                                                                          " > ")}
                                                             (fn [choice-2]
                                                               (when (vim.tbl_contains options
                                                                                       choice-2)
                                                                 (set-forcibly! choice-2
                                                                                (. choice_edge_case
                                                                                   choice-2)))
                                                               (vim.cmd (.. "Octo "
                                                                            ch
                                                                            " "
                                                                            choice
                                                                            " "
                                                                            choice-2)))))
                                             (fn []
                                               (vim.cmd (.. "Octo " ch " "
                                                            choice)))))
                               (fn []
                                 (vim.notify "No Optional Params listed")
                                 (when (and (not= choice nil) (not= ch nil))
                                   (global command (.. "Octo " ch " " choice))
                                   (vim.cmd command)))))))

;;===============================================================;;
;; NOTE: Neotest Utils
;; Most of these are boilerplates, wonder if theirs a filetype macro for this BS
;; FIX:: we need these to be ((. (require ...., it's a function over an empty arg, hence the second (

(fn test_class []
  (when (= vim.bo.filetype :python)
      ((. (require :dap-python) :test_class))))

(fn debug_selection []
  (when (= vim.bo.filetype :python)
      ((. (require :dap-python) :debug_selection))))

(fn test_method []
  (when (= vim.bo.filetype :python)
      ((. (require :dap-python) :test_method))))

;;===============================================================;;
;; NOTE:: Flash Utils
(fn treejump []
  "Jump Using Treesitter-nodes"
  (local win (vim.api.nvim_get_current_win))
  (local view (vim.fn.winsaveview))
  ((. (require :flash) :jump) {:action (fn  [matched state]
                                         (state:hide)
                                         (vim.api.nvim_set_current_win matched.win))}))
(fn tree_bounce []
  "Jump to a position, make a treesitter-based selection, and jump backwards"
  (local win (vim.api.nvim_get_current_win))
  (local view (vim.fn.winsaveview))
  (local configs {:action (fn [matched state]
                            (: state :hide)
                            (vim.api.nvim_set_current_win matched.win)
                            (vim.api.nvim_win_set_cursor matched.win matched.pos)
                            ((->> :treesitter
                                 (. (require :flash))))
                            (vim.schedule (fn []
                                            (vim.api.nvim_set_current_win win)
                                            (vim.fn.winrestview view))))})
  ((->> :jump
        (. (require :flash))) configs))
  
  
(fn win_select []
  (local win (vim.api.nvim_get_current_win))
  (local view (vim.fn.winsaveview))
  (local configs {:pattern "."
                  :jump {:pos :range}
                  :search {:mode (fn [pattern]
                                   "Searches For word, using the pattern and the skippable pattern {e.g:: '.'}"
                                   (when (= (pattern:sub 1 1) ".")
                                       (set-forcibly! pattern (pattern:sub 2)))
                                   (values (: "\\v<%s\\w*>" :format pattern)
                                           (: "\\v<%s" :format pattern)))}})
  ((->> :jump
        (. (require :flash))) configs))
;; Custom window jump function

(fn get_windows []
  (let [wins (vim.api.nvim_tabpage_list_wins 0)
        curr-win (vim.api.nvim_get_current_win)]
    (fn check [win]
      (let [config (vim.api.nvim_win_get_config win)]
        (and (and config.focusable (= config.relative "")) (not= win curr-win))))

    (vim.tbl_filter check wins)))

(fn matcher []
 (vim.tbl_map (fn [window]
                (let [wininfo (. (vim.fn.getwininfo window) 1)]
                  {:end_pos [wininfo.topline 0] :pos [wininfo.topline 1]}))
              (get_windows)))

;; Takes Current window, and shifts to another window
(fn jump_window []
  (let [config {:search {:multi_window true :wrap true}
                :highlight {:backdrop true
                            :label {:current true}}
                :matcher (fn []
                           (vim.tbl_map (fn [window]
                                          (local wininfo (. (vim.fn.getwininfo window) 1))
                                          {:pos [wininfo.topline  1]
                                           :end_pos [wininfo.topline 0]})
                                        (get_windows)))
                :action (fn [matched _]
                          (vim.api.nvim_set_current_win matched.win)
                          (vim.api.nvim_win_call matched.win (fn []
                                                               (vim.api.nvim_win_set_cursor matched.win
                                                                                            [(. matched.pos 1) 0]))))}]
    ;; This just looks cooler:: we go (->> required plugin_cmd (req plugin) ) _args_
   ((->> :jump
        (. (require :flash))) config)))

;;===============================================================;;
;; Lazy-Requires::
;; SOURCE:: https://github.com/tjdevries/lazy-require.nvim

(fn lazy-reqidx [path]
  "
    Only requires a value within a metatable when the table has been index.
    This allows for an (autoload!)-like feature for modules, insanely useful for utils.
  "
  (setmetatable {} {:__index (fn [_ key]
                               (. (require :path)key))
                    :__newindex (fn [_ key value]
                                  (tset (require :path) key value))}))

;;===============================================================;;

{: plane
 : test_class
 : test_method
 : debug_selection
 : tmux-goto
 : terminal-send
 : treejump
 : handle-tmux
 : handle-non-tmux
 : handle-command-input
 : jump_window
 : win_select
 : tree_bounce
 : caller}
