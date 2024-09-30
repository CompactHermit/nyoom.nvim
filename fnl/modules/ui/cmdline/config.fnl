;; Shamelessly Stolen, will port my own version once I understand this better
(local cmd {})
(fn concat [chunks]
  (var _c "")
  (each [_ chunk (ipairs chunks)]
    (set _c (.. _c (. chunk 2))))
  _c)

(fn run [tbl ...]
  (let [_o {}]
    (each [key value (pairs tbl)]
      (if (= (type value) :function)
          (if (pcall value ...) (tset _o key (value ...)) (tset _o key false))
          (tset _o key value)))
    _o))

(set cmd.conf {:cmp_height 7
               :completion_custom [{:cmd :^h
                                    :hl :CmdYellow
                                    :icon [[" 󰮥 " :CmdYellow]]}
                                   {:cmd :^Telescope
                                    :hl :CmdGreen
                                    :icon [[" 󰺮 " :CmdGreen]]}]
               :completion_default {:hl :CmdViolet
                                    :icon [["  " :CmdViolet]]}
               :configs [{:input true
                          :winhl (fn [state] (local prompt state.prompt)
                                   (if (prompt:match "^Create:%s")
                                       "FloatBorder:CmdGreen,Normal:Normal"
                                       (prompt:match "^Rename:%s")
                                       "FloatBorder:CmdYellow,Normal:Normal"
                                       (prompt:match "^Remove selection")
                                       "FloatBorder:CmdRed,Normal:Normal"
                                       "FloatBorder:CmdGrey,Normal:Normal"))
                          :winopts (fn [state]
                                     (local prompt state.prompt)
                                     (if (prompt:match "^Create:%s")
                                         {:footer [["╼" :CmdGreen]
                                                   [" Confirm: " :Normal]
                                                   ["<CR> " :Special]
                                                   ["╾" :CmdGreen]]
                                          :title [["" :CmdGreen]
                                                  [" 󰙴 Create " :CmdGreenBg]
                                                  ["" :CmdGreen]]
                                          :title_pos :right}
                                         (prompt:match "^Rename:%s")
                                         {:footer [["╼" :CmdYellow]
                                                   [" Confirm: " :Normal]
                                                   ["<CR> " :Special]
                                                   ["╾" :CmdYellow]]
                                          :title [["" :CmdYellow]
                                                  [" 󰬲 Rename "
                                                   :CmdYellowBg]
                                                  ["" :CmdYellow]]
                                          :title_pos :right}
                                         (prompt:match "^Remove selection")
                                         (do
                                           (local items (prompt:match "(%d+)"))
                                           {:footer [["╼" :CmdRed]
                                                     [" [y/N]" :Special]
                                                     [", Confirm: " :Normal]
                                                     ["<CR> " :Special]
                                                     ["╾" :CmdRed]]
                                            :title [["" :CmdRed]
                                                    [(.. " 󰆴 Delete: " items
                                                         (or (and (= (tonumber items)
                                                                     1)
                                                                  " item ")
                                                             " items "))
                                                     :CmdRedBg]
                                                    ["" :CmdRed]]
                                            :title_pos :right})
                                         {:title [["" :CmdGrey]
                                                  [(.. " "
                                                       (or state.prompt
                                                           "Input:")
                                                       " ")
                                                   :CmdGreyBg]
                                                  ["" :CmdGrey]]}))}
                         {:firstc ":" :icon [["  " :CmdYellow]] :match :^s/}
                         {:firstc ":"
                          :icon [["  " :CmdOrange]]
                          :match "^%d+,%d+s/"}
                         {:firstc ":"
                          :ft :lua
                          :icon [["  " :CmdBlue]]
                          :match "^="
                          :text (fn [inp] (inp:gsub "^=" ""))}
                         {:firstc ":"
                          :ft :lua
                          :icon [["  " :CmdViolet]]
                          :match "^lua%s"
                          :text (fn [inp]
                                  (local init (inp:gsub :^lua ""))
                                  (when (init:match "^(%s+)")
                                    (let [___antifnl_rtn_1___ (init:gsub "^%s+"
                                                                         "")]
                                      (lua "return ___antifnl_rtn_1___")))
                                  init)
                          :winhl "FloatBorder:CmdViolet,Normal:Normal"
                          :winopts {:title [["" :CmdViolet]
                                            [(.. "  " _VERSION " ")
                                             :CmdVioletBg]
                                            ["" :CmdViolet]]
                                    :title_pos :right}}
                         {:firstc ":"
                          :icon [[" 󰭎 " :CmdYellow]]
                          :match :^Telescope}
                         {:firstc ":"
                          :icon [["  " :MiniIconsYellow]]
                          :match :^Fnl}
                         {:firstc ":"
                          :icon [["  " :MiniIconsRed]]
                          :match :^Rust}
                         {:firstc ":"
                          :icon [["  " :MiniIconsPurple]]
                          :match :^Haskell}
                         {:firstc "?"
                          :icon [["  " :CmdOrange]]
                          :winhl "FloatBorder:CmdOrange,Normal:Normal"
                          :winopts {:title [["" :CmdOrange]
                                            [" 󰍉 Search " :CmdOrangeBg]
                                            ["" :CmdOrange]]
                                    :title_pos :right}}
                         {:firstc "/"
                          :icon [["  " :CmdYellow]]
                          :winhl "FloatBorder:CmdYellow,Normal:Normal"
                          :winopts {:title [["" :CmdYellow]
                                            [" 󰍉 Search " :CmdYellowBg]
                                            ["" :CmdYellow]]
                                    :title_pos :right}}
                         {:firstc "="
                          :icon [[" 󰇼 " :CmdGreen]]
                          :winhl "FloatBorder:CmdGreen,Normal:Normal"
                          :winopts {:title [["" :CmdGreen]
                                            ["  Calculate " :CmdGreenBg]
                                            ["" :CmdGreen]]
                                    :title_pos :right}}]
               :default {:ft :vim
                         :icon [[" 󰣖 " :CmdBlue]]
                         :winhl "FloatBorder:CmdBlue,Normal:Normal"
                         :winopts {:title [["" :CmdBlue]
                                           ["  " :CmdBlueBg]
                                           [(.. :v (. (vim.version) :major) "."
                                                (. (vim.version) :minor) " ")
                                            :CmdBlueBg]
                                           ["" :CmdBlue]]
                                   :title_pos :right}}
               :width (math.floor (* 0.6 vim.o.columns))})

(set cmd.current_conf {})
(set cmd.cursor nil)
(set cmd.ns (vim.api.nvim_create_namespace :cmd))
(set cmd.buf (vim.api.nvim_create_buf false true))
(set cmd.win nil)
(set cmd.state {})
(set cmd.comp_buf (vim.api.nvim_create_buf false true))
(set cmd.comp_win nil)
(set cmd.comp_state {})
(set cmd.comp_enable false)
(set cmd.comp_txt nil)
(fn cmd.update_state [state]
  (set cmd.state (vim.tbl_deep_extend :force cmd.state state))
  (local txt (concat cmd.state.content))
  (each [_ conf (ipairs cmd.conf.configs)]
    (if (= conf.firstc cmd.state.firstc)
        (if (and conf.match (txt:match conf.match))
            (do
              (set cmd.current_conf conf)
              (lua "return "))
            (not conf.match)
            (do
              (set cmd.current_conf conf)
              (lua "return ")))
        (and (and (not conf.firstc) conf.match) (txt:match conf.match))
        (do
          (set cmd.current_conf conf)
          (lua "return "))
        (and (and state.prompt (not= state.prompt "")) conf.input)
        (do
          (set cmd.current_conf (run conf cmd.state))
          (lua "return "))))
  (set cmd.current_conf cmd.conf.default))

(fn cmd.update_comp_state [state]
  (set cmd.comp_state (vim.tbl_deep_extend :force cmd.comp_state state)))

(fn cmd.open []
  (let [w (or (and (< cmd.conf.width 1)
                   (math.floor (* vim.o.columns cmd.conf.width)))
              cmd.conf.width)
        h 3
        cmp-h (or cmd.conf.cmp_height 7)]
    (when (and cmd.win (vim.api.nvim_win_is_valid cmd.win))
      (vim.api.nvim_win_set_config cmd.win
                                   (vim.tbl_extend :force
                                                   {:col (math.floor (/ (- vim.o.columns
                                                                           w)
                                                                        2))
                                                    :height (math.max 1 (- h 2))
                                                    :relative :editor
                                                    :row (or (and (= cmd.comp_enable
                                                                     true)
                                                                  (math.floor (/ (- vim.o.lines
                                                                                    (+ h
                                                                                       cmp-h))
                                                                                 2)))
                                                             (math.floor (/ (- vim.o.lines
                                                                               h)
                                                                            2)))
                                                    :width w}
                                                   (or cmd.current_conf.winopts
                                                       {})))
      (when cmd.current_conf.winhl
        (tset (. vim.wo cmd.win) :winhighlight cmd.current_conf.winhl))
      (when cmd.current_conf.ft
        (tset (. vim.bo cmd.buf) :filetype cmd.current_conf.ft))
      (when (or (not cmd.comp_win)
                (not (vim.api.nvim_win_is_valid cmd.comp_win)))
        (lua "return "))
      (vim.api.nvim_win_set_config cmd.comp_win
                                   {:col (math.floor (/ (- vim.o.columns w) 2))
                                    :relative :editor
                                    :row (+ (math.floor (/ (- vim.o.lines
                                                              (+ h cmp-h))
                                                           2))
                                            h)})
      (lua "return "))
    (set cmd.win
         (vim.api.nvim_open_win cmd.buf false
                                (vim.tbl_extend :force
                                                {:border :rounded
                                                 :col (math.floor (/ (- vim.o.columns
                                                                        w)
                                                                     2))
                                                 :height (math.max 1 (- h 2))
                                                 :relative :editor
                                                 :row (or (and (= cmd.comp_enable
                                                                  true)
                                                               (math.floor (/ (- vim.o.lines
                                                                                 (+ h
                                                                                    cmp-h))
                                                                              2)))
                                                          (math.floor (/ (- vim.o.lines
                                                                            h)
                                                                         2)))
                                                 :width w
                                                 :zindex 500}
                                                (or cmd.current_conf.winopts {}))))
    (tset (. vim.wo cmd.win) :number false)
    (tset (. vim.wo cmd.win) :relativenumber false)
    (tset (. vim.wo cmd.win) :statuscolumn "")
    (tset (. vim.wo cmd.win) :wrap false)
    (tset (. vim.wo cmd.win) :spell false)
    (tset (. vim.wo cmd.win) :cursorline false)
    (tset (. vim.wo cmd.win) :sidescrolloff 10)
    (if (not= vim.opt.guicursor "") (set cmd.cursor vim.opt.guicursor)
        (set cmd.cursor "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"))
    (set vim.opt.guicursor "a:CursorHidden")
    (when cmd.current_conf.winhl
      (tset (. vim.wo cmd.win) :winhighlight cmd.current_conf.winhl))
    (when cmd.current_conf.ft
      (tset (. vim.bo cmd.buf) :filetype cmd.current_conf.ft))))

(fn cmd.open_completion []
  (when (vim.tbl_isempty cmd.comp_state) (lua "return "))
  (local w (or (and (< cmd.conf.width 1)
                    (math.floor (* vim.o.columns cmd.conf.width)))
               cmd.conf.width))
  (local h 3)
  (local cmp-h (or cmd.conf.cmp_height 7))
  (when (and cmd.comp_win (vim.api.nvim_win_is_valid cmd.comp_win))
    (vim.api.nvim_win_set_config cmd.win
                                 (vim.tbl_extend :force
                                                 {:col (math.floor (/ (- vim.o.columns
                                                                         w)
                                                                      2))
                                                  :height (math.max 1 (- h 2))
                                                  :relative :editor
                                                  :row (math.floor (/ (- vim.o.lines
                                                                         (+ h
                                                                            cmp-h))
                                                                      2))
                                                  :width w}
                                                 (or cmd.current_conf.winopts
                                                     {})))
    (vim.api.nvim_win_set_config cmd.comp_win
                                 {:col (math.floor (/ (- vim.o.columns w) 2))
                                  :height (math.max 1 (- h 2))
                                  :relative :editor
                                  :row (math.floor (/ (- vim.o.lines cmp-h) 2))
                                  :width w})
    (when cmd.current_conf.winhl
      (tset (. vim.wo cmd.win) :winhighlight cmd.current_conf.winhl))
    (when cmd.current_conf.ft
      (tset (. vim.bo cmd.buf) :filetype cmd.current_conf.ft))
    (lua "return "))
  (vim.api.nvim_win_set_config cmd.win
                               (vim.tbl_extend :force
                                               {:col (math.floor (/ (- vim.o.columns
                                                                       w)
                                                                    2))
                                                :height (math.max 1 (- h 2))
                                                :relative :editor
                                                :row (math.floor (/ (- vim.o.lines
                                                                       (+ h
                                                                          cmp-h))
                                                                    2))
                                                :width w}
                                               (or cmd.current_conf.winopts {})))
  (set cmd.comp_win (vim.api.nvim_open_win cmd.comp_buf false
                                           {:border :rounded
                                            :col (math.floor (/ (- vim.o.columns
                                                                   w)
                                                                2))
                                            :height (math.max 1 (- cmp-h 0))
                                            :relative :editor
                                            :row (+ (math.floor (/ (- vim.o.lines
                                                                      (+ h
                                                                         cmp-h))
                                                                   2))
                                                    h)
                                            :width w
                                            :zindex 500}))
  (tset (. vim.wo cmd.comp_win) :number false)
  (tset (. vim.wo cmd.comp_win) :relativenumber false)
  (tset (. vim.wo cmd.comp_win) :statuscolumn "")
  (tset (. vim.wo cmd.comp_win) :wrap false)
  (tset (. vim.wo cmd.comp_win) :spell false)
  (tset (. vim.wo cmd.comp_win) :scrolloff 30)
  (tset (. vim.wo cmd.comp_win) :cursorline true))

(fn cmd.close [] (when (> cmd.state.level 1) (lua "return "))
  (pcall vim.api.nvim_win_close cmd.win true)
  (pcall vim.api.nvim_win_close cmd.comp_win true)
  (set cmd.win nil)
  (set cmd.comp_win nil)
  (set vim.opt.guicursor cmd.cursor))

(fn cmd.close_completion [] (pcall vim.api.nvim_win_close cmd.comp_win true)
  (set cmd.comp_win nil))

(fn cmd.draw []
  (when (or (not cmd.state) (not cmd.state.content)) (lua "return "))
  (var txt "")
  (var diff 0)
  (each [_ part (ipairs cmd.state.content)]
    (set txt (.. txt (. part 2))))
  (when (and cmd.current_conf.text (pcall cmd.current_conf.text txt))
    (local tmp (cmd.current_conf.text txt))
    (when (< (- (length txt) (length tmp)) cmd.state.position)
      (set diff (- (length txt) (length tmp)))
      (set txt tmp)))
  (vim.api.nvim_buf_set_lines cmd.buf 0 (- 1) false [txt])
  (vim.api.nvim_win_set_cursor cmd.win [1 cmd.state.position])
  (vim.api.nvim_buf_clear_namespace cmd.buf cmd.ns 0 (- 1))
  (when cmd.current_conf.icon
    (vim.api.nvim_buf_set_extmark cmd.buf cmd.ns 0 0
                                  {:virt_text cmd.current_conf.icon
                                   :virt_text_pos :inline}))
  (if (>= cmd.state.position (+ (length txt) diff))
      (vim.api.nvim_buf_set_extmark cmd.buf cmd.ns 0 (length txt)
                                    {:virt_text [[" " :Cursor]]
                                     :virt_text_pos :inline})
      (let [before (string.sub txt 0 (- cmd.state.position diff))]
        (vim.api.nvim_buf_add_highlight cmd.buf cmd.ns :Cursor 0
                                        (- cmd.state.position diff)
                                        (length (vim.fn.strcharpart txt 0
                                                                    (+ (vim.fn.strchars before)
                                                                       1)))))))

(fn cmd.draw_completion []
  (vim.api.nvim_buf_clear_namespace cmd.comp_buf cmd.ns 0 (- 1))
  (vim.api.nvim_buf_set_lines cmd.comp_buf 0 (- 1) false {})
  (when (not cmd.comp_txt)
    (set cmd.comp_txt "")
    (each [_ part (ipairs cmd.state.content)]
      (set cmd.comp_txt (.. cmd.comp_txt (. part 2)))))
  (local last-str (cmd.comp_txt:match "([^%s%.]+)$"))
  (each [c completion (ipairs cmd.comp_state.items)]
    (vim.fn.setbufline cmd.comp_buf c [(. completion 1)])
    (var _c cmd.conf.completion_default)
    (each [_ conf (ipairs cmd.conf.completion_custom)]
      (if (and conf.match (: (. completion 1) :match conf.match)) (set _c conf)
          (and conf.cmd (cmd.comp_txt:match conf.cmd)) (set _c conf)))
    (when _c.icon
      (vim.api.nvim_buf_set_extmark cmd.comp_buf cmd.ns (- c 1) 0
                                    {:hl_mode :combine
                                     :virt_text _c.icon
                                     :virt_text_pos :inline}))
    (when last-str
      (local (hl-from hl-to) (: (. completion 1) :find last-str))
      (when (and hl-from hl-to)
        (vim.api.nvim_buf_add_highlight cmd.comp_buf cmd.ns (or _c.hl :Special)
                                        (- c 1) (- hl-from 1) hl-to))))
  (when (and cmd.comp_state.selected (not= cmd.comp_state.selected (- 1)))
    (vim.api.nvim_win_set_cursor cmd.comp_win [(+ cmd.comp_state.selected 1) 0])))

(vim.ui_attach cmd.ns {:ext_cmdline true :ext_popupmenu true}
               (fn [event ...]
                 (if (= event :cmdline_show)
                     (let [(content pos firstc prompt indent level) ...]
                       (cmd.update_state {: content
                                          : firstc
                                          : indent
                                          : level
                                          :position pos
                                          : prompt})
                       (cmd.open)
                       (cmd.draw)
                       (vim.api.nvim__redraw {:flush true :win cmd.win}))
                     (= event :cmdline_hide)
                     (do
                       (cmd.close)
                       (set cmd.state {})
                       (set cmd.comp_state {})
                       (vim.api.nvim__redraw {:flush true :win cmd.win}))
                     (= event :cmdline_pos)
                     (let [(pos level) ...]
                       (cmd.update_state {: level :position pos})
                       (cmd.draw)
                       (vim.api.nvim__redraw {:flush true :win cmd.win}))
                     (= event :popupmenu_show)
                     (let [(items selected row col grid) ...]
                       (cmd.update_comp_state {: col
                                               : grid
                                               : items
                                               : row
                                               : selected})
                       (set cmd.comp_enable true)
                       (cmd.open_completion)
                       (cmd.draw_completion))
                     (= event :popupmenu_select)
                     (let [selected ...] (cmd.update_comp_state {: selected})
                       (cmd.draw_completion)
                       (vim.api.nvim__redraw {:flush true :win cmd.comp_win}))
                     (= event :popupmenu_hide)
                     (do
                       (set cmd.comp_enable false)
                       (set cmd.comp_txt nil)
                       (cmd.close_completion)))))

cmd
