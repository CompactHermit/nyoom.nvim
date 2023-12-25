(import-macros {: set! : colorscheme : nyoom-module-p! : augroup! : autocmd!}
               :macros)

(local {: hydra-key!} (require :util.hydra))
; (import-macros {: hydra-key!}  :util.hydra)
;; BUG:: hydra-key! ignores the ?num arg
(local Hydra (autoload :hydra))

;; fnlfmt: skip
;; NOTE!:: The formatter will butcher this file, donnot, under any circumstance, remove this!

;; Git boi ;;
(nyoom-module-p! vc-gutter
                 (do
                   (local {: toggle_linehl
                           : toggle_deleted
                           : next_hunk
                           : prev_hunk
                           : undo_stage_hunk
                           : stage_buffer
                           : preview_hunk
                           : toggle_deleted
                           : blame_line
                           : show}
                          (autoload :gitsigns))
                   (local git-hint "
                    Git

    _J_: next hunk     _d_: show deleted
    _K_: prev hunk     _u_: undo last stage
    _s_: stage hunk    _/_: show base file
    _p_: preview hunk  _S_: stage buffer
    _b_: blame line    _B_: blame show full
  ^
    _<Enter>_: Neogit       _<Esc>_: Exit
      ")
                   (Hydra {:name :+git
                           :hint git-hint
                           :mode [:n :x]
                           :body :<leader>g
                           :config {:buffer bufnr
                                    :color :red
                                    :invoke_on_body true
                                    :hint {:border :solid :position :middle}
                                    :on_key (fn []
                                              (vim.wait 50))
                                    :on_enter (fn []
                                                (vim.cmd.mkview)
                                                (vim.cmd "silent! %foldopen!")
                                                (toggle_linehl true))
                                    :on_exit (fn []
                                               (local cursor-pos
                                                      (vim.api.nvim_win_get_cursor 0))
                                               (vim.cmd.loadview)
                                               (vim.api.nvim_win_set_cursor 0
                                                                            cursor-pos)
                                               (vim.cmd.normal :zv)
                                               (toggle_linehl false)
                                               (toggle_deleted false))}
                           :heads [[:J
                                    (fn []
                                      (when vim.wo.diff
                                        (lua "return \"]c\""))
                                      (vim.schedule (fn []
                                                      (next_hunk)))
                                      :<Ignore>)
                                    {:expr true :desc "next hunk"}]
                                   [:K
                                    (fn []
                                      (when vim.wo.diff
                                        (lua "return \"[c\""))
                                      (vim.schedule (fn []
                                                      (prev_hunk)))
                                      :<Ignore>)
                                    {:expr true :desc "prev hunk"}]
                                   [:s
                                    (fn []
                                      (local mode
                                             (: (. (vim.api.nvim_get_mode)
                                                   :mode)
                                                :sub 1 1))
                                      (if (= mode :V)
                                          (do
                                            (local esc
                                                   (vim.api.nvim_replace_termcodes :<Esc>
                                                                                   true
                                                                                   true
                                                                                   true))
                                            (vim.api.nvim_feedkeys esc :x false)
                                            (vim.cmd "'<,'>Gitsigns stage_hunk"))
                                          (vim.cmd.Gitsigns :stage_hunk)))
                                    {:desc "stage hunk"}]
                                   [:u
                                    undo_stage_hunk
                                    {:desc "undo last stage"}]
                                   [:S stage_buffer {:desc "stage buffer"}]
                                   [:p preview_hunk {:desc "preview hunk"}]
                                   [:d
                                    toggle_deleted
                                    {:nowait true :desc "toggle deleted"}]
                                   [:b blame_line {:desc :blame}]
                                   [:B
                                    (fn []
                                      blame_line
                                      {:full true})
                                    {:desc "blame show full"}]
                                   ["/"
                                    show
                                    {:exit true :desc "show base file"}]
                                   [:<Enter>
                                    (fn []
                                      (vim.cmd :Neogit))
                                    {:exit true :desc :Neogit}]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Options ;;
(nyoom-module-p! nyoom
                 (do
                   (local options-hint "
    ^ ^        Options
    ^
    _v_ %{ve} virtual edit
    _i_ %{list} invisible characters
    _s_ %{spell} spell
    _w_ %{wrap} wrap
    _c_ %{cul} cursor line
    _n_ %{nu} number
    _r_ %{rnu} relative number
    _b_ Toggle Background
    ^
         ^^^^              _<Esc>_
    ")
                   (Hydra {:name :+options
                           :hint options-hint
                           :config {:color :amaranth
                                    :invoke_on_body true
                                    :hint {:border :solid :position :middle}}
                           :mode [:n :x]
                           :body :<leader>v
                           :heads [[:b
                                    (fn []
                                      (if (= vim.o.background :dark)
                                          (set! background :light)
                                          (set! background :dark)))
                                    {:desc :Background}]
                                   [:n
                                    (fn []
                                      (if (= vim.o.number true)
                                          (set! nonumber)
                                          (set! number)))
                                    {:desc :number}]
                                   [:r
                                    (fn []
                                      (if (= vim.o.relativenumber true)
                                          (set! norelativenumber)
                                          (do
                                            (set! number)
                                            (set! relativenumber))))
                                    {:desc :relativenumber}]
                                   [:v
                                    (fn []
                                      (if (= vim.o.virtualedit :all)
                                          (set! virtualedit :block)
                                          (set! virtualedit :all)))
                                    {:desc :virtualedit}]
                                   [:i
                                    (fn []
                                      (if (= vim.o.list true)
                                          (set! nolist)
                                          (set! list)))
                                    {:desc "show invisible"}]
                                   [:s
                                    (fn []
                                      (if (= vim.o.spell true)
                                          (set! nospell)
                                          (set! spell)))
                                    {:exit true :desc :spell}]
                                   [:w
                                    (fn []
                                      (if (= vim.o.wrap true)
                                          (set! nowrap)
                                          (set! wrap)))
                                    {:desc :wrap}]
                                   [:c
                                    (fn []
                                      (if (= vim.o.cursorline true)
                                          (set! nocursorline)
                                          (set! cursorline)))
                                    {:desc "cursor line"}]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Harpoon ;;
; (nyoom-module-p! harpoon
;                  (do
;                    (local cache {:command "ls -a" :tmux {:selected_plane ""}})
;                    (local {: plane
;                            : tmux-goto
;                            : terminal-send
;                            : handle-tmux
;                            : handle-non-tmux
;                            : handle-command-input}
;                           (require :util))
;                    (local harpoon-hints "
;         ^^Harpoooooooooooon
;         ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔^
;         ^^_s_: Terminal Gotosend
;         ^^_S_: Terminal goto
;         ^^_N_:Previous file
;         ^^_w_: Toggle goto
;         ^^_W_: Jump file
;        ^^_a_: Add file
;         ^^_n_: Next file
;         ^^_T_: Harpoon Telescope
;         ^^_<leader>_: Quick ui Menu
;         ^^_t_: Toggle file
;         ^^_c_: Clear Marks
;     ")
;                    (Hydra {:name :Harpoon
;                            :hint harpoon-hints
;                            :config {:color :teal
;                                     :invoke_on_body true
;                                     :hint {:border :solid
;                                            :position :middle-right}}
;                            :body :<leader>a
;                            :heads [[:s
;                                     #()]
;                                    [:S]
;                                    [:w]
;                                    [:c
;                                     #()]
;                                    [:W
;                                     #()]
;                                    [:t
;                                     #(fn []
;                                        ())]
;                                    [:T
;                                     (fn []
;                                       ())]
;                                    [:a
;                                     (fn []
;                                       ())]
;                                    [:n
;                                     (fn []
;                                       ())]
;                                    [:N
;                                     (fn []
;                                       ())]
;                                    [:<leader>
;                                     (fn []
;                                       ())]
;                                    [:<Esc> nil {:exit true :nowait true}]]})))
;
;; Tmux ;;
; (nyoom-module-p! tmux
;                  (do
;                    (fn tmux-split [tmux percentage external-command]
;                      (when (not= external-command nil)
;                        (set-forcibly! external-command
;                                       (or external-command "nvim .")))
;                      (global command
;                              (.. "tmux split-window -" tmux " -p " percentage))
;                      (when (not= external-command nil)
;                        (global command (.. command " '" external-command "'")))
;                      (os.execute command))
;                    (local tmux-hints "
;      ^^ Tmux ^^
;     ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔^
;      ^^_s_:Horizontal split
;      ^^_S_:Vert Split
;      ^^_p_:Previous window
;     ^^_n_:Move back
;      ^^_N_:Move formward
;      ^^_t_:TMUX Sessions
;      ^^_<Esc>_:
;     ")
;                    (Hydra {:name :Tmux
;                            :hint tmux-hints
;                            :config {:color :teal
;                                     :invoke_on_body true
;                                     :hint {:border :solid
;                                            :position :middle-right}}
;                            :body :<leader>z
;                            :heads [[:s
;                                     #(vim.ui.input {:default :40
;                                                     :prompt "Horz-split % : "}
;                                                    (fn [percent]
;                                                      (tmux-split :v
;                                                                  (tonumber percent))))
;                                     {:desc "Horizontal Tmux split"}]
;                                    [:S
;                                     #(vim.ui.input {:default :40
;                                                     :prompt "Vert-split % : "}
;                                                    (fn [percent]
;                                                      (tmux-split :h
;                                                                  (tonumber percent))))
;                                     {:desc "Vertical Tmux split"}]
;                                    [:n
;                                     #(os.execute "tmux select-window -p")
;                                     {:desc "Move backwards"}]
;                                    [:N
;                                     #(os.execute "tmux select-window -n")
;                                     {:desc "Move forward"}]
;                                    [:t
;                                     (fn []
;                                       (vim.cmd "Telescope tmux windows"))
;                                     {:nowait true
;                                      :exit true
;                                      :desc "Switch Session"}]
;                                    [:p #(os.execute "tmux select-window -l")]
;                                    [:<Esc> nil {:exit true :nowait true}]]})))

;; Octussy ;;
(nyoom-module-p! octo
                 (do
                   (local {: caller} (require :util))
                   (local octo-hints "
^    Octo
^▔▔▔▔▔▔▔▔▔▔▔^
^▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔^
^ _g_: Gists
^ _i_: Issues
^ _p_: PR
^ _r_: Repos
^ _s_: Search
^ _C_: Card
^ _c_: Comment
^ _l_: label
^ _t_: thread
^ _R_: Review
^ _-_: React
^ <Esc>: Quit
^▔▔▔▔▔▔▔▔▔▔▔^
    ")
                   (Hydra {:name :+Octo
                           :hint octo-hints
                           :config {:color :teal
                                    :invoke_on_body true
                                    :hint {:border :solid
                                           :position :middle-right}}
                           :mode [:n :v]
                           :body :<leader>o
                           :heads [[:g
                                    (fn []
                                      (caller [:list] :gist))
                                    {:exit true}]
                                   [:i
                                    (fn []
                                      (local options
                                             [:close
                                              :create
                                              :edit
                                              :list
                                              :search
                                              :reload
                                              :browser
                                              :url])
                                      (caller options :issue))
                                    {:exit true}]
                                   [:p
                                    (fn []
                                      (local options
                                             [:create
                                              :list
                                              :search
                                              :edit
                                              :reopen
                                              :checkout
                                              :commits
                                              :changes
                                              :diff
                                              :ready
                                              :merge
                                              :checks
                                              :reload
                                              :url])
                                      (caller options :pr))
                                    {:exit true}]
                                   [:r
                                    (fn []
                                      (local options
                                             [:list :fork :browser :url :view])
                                      (caller options :repo))
                                    {:exit true}]
                                   [:s
                                    #(vim.ui.input {:prompt "Enter a option for search >"
                                                    :default "assignee:CompactHermit is:pr"}
                                                   (fn [choice_2]
                                                     (vim.cmd (.. "Octo search"
                                                                  choice_2))))
                                    {:exit true}]
                                   [:C
                                    (fn []
                                      (local options [:add :remove :move])
                                      (caller options :card))
                                    {:exit true}]
                                   [:c
                                    (fn []
                                      (local options [:add :delete])
                                      (caller options :comment))
                                    {:exit true}]
                                   [:R
                                    (fn []
                                      (local options
                                             [:start
                                              :submit
                                              :resume
                                              :discard
                                              :comments
                                              :commit
                                              :close])
                                      (caller options :review))
                                    {:exit true}]
                                   [:t
                                    (fn []
                                      (caller [:resolve :unresolve] :threat))
                                    {:exit true}]
                                   [:l
                                    (fn []
                                      (local options [:add "remove:" :create])
                                      (caller options :label))
                                    {:exit true}]
                                   ["-"
                                    (fn []
                                      (local options
                                             [:thummbs_up
                                              :thumbs_down
                                              :eyes
                                              :laugh
                                              :confused
                                              :rocket
                                              :heart
                                              :hooray
                                              :party
                                              :tada])
                                      (vim.notify :Active)
                                      (caller options :reaction))]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Browser ::
(nyoom-module-p! browse
                 (do
                   (local browse-hints "
    ^ ^     Browser   ^ ^
    _w_: Browse
    _W_: Default browse
    _d_: DevDocsOpen
    _D_: DevDocsFT
    _K_: DevDocCursor
    _s_: Search DDG
    _S_: Updoc Searcher
    _z_: Zeal Searcher
    ^^^_<Esc>_:escape
             ^ ^
                         ")
                   (Hydra {:name :Browser
                           :hint browse-hints
                           :config {:color :teal
                                    :invoke_on_body true
                                    :timeout false
                                    :hint {:type :window
                                           :border :solid
                                           :position :middle-right}}
                           :body :<leader>q
                           :heads [[:w
                                    (fn []
                                      (vim.cmd "lua require('browse').browse()"))]
                                   [:W
                                    (fn []
                                      (vim.cmd "lua require('browse').browse({ bookmarks = bookmarks['default'] })"))
                                    {:exit true}]
                                   [:s
                                    (fn []
                                      (vim.cmd "lua require('browse').input_search()"))]
                                   [:d
                                    (fn []
                                      (vim.cmd :DevdocsOpen))]
                                   [:D
                                    (fn []
                                      (vim.cmd "lua require('browse.devdocs').search_with_filetype()"))]
                                   [:K
                                    (fn []
                                      (vim.cmd :DD))]
                                   [:S
                                    (fn []
                                      (vim.cmd "lua require('updoc').search()"))]
                                   [:z
                                    (fn []
                                      (vim.cmd :Zeavim))]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Neotest ;;
(nyoom-module-p! neotest
                 (do
                   (local {: test_class : test_method : debug_selection}
                          (require :util))
                   (local neotest-hints "
 ^    Neotest
 ^▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔^

 ^▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔^
 ^^_<leader>_: Test Near
 ^^ _c_: Test Current
 ^^ _o_: Test Output
 ^^ _s_: Test Summary
 ^^ _S_: Test Strat
 ^^ _D_: Test Stop
 ^^ _a_: Test Attach
 ^^ _C_: Test Class
 ^^ _m_: Test Method
 ^^ _d_: Debug Selection
 ^^ _<Esc>_: Escape

    ")
                   (Hydra {:name :+Neotest
                           :hint neotest-hints
                           :config {:color :pink
                                    :invoke_on_body true
                                    :hint {:border :solid
                                           :position :middle-right}}
                           :mode [:n :v :x :o]
                           :body :<leader>u
                           :heads [[:<leader>
                                    (fn []
                                      (vim.cmd :TestNear))]
                                   [:c
                                    (fn []
                                      (vim.cmd :TestCurrent))]
                                   [:o
                                    (fn []
                                      (vim.cmd :TestOutput))]
                                   [:s
                                    (fn []
                                      (vim.cmd :TestSummary))]
                                   [:S
                                    (fn []
                                      (vim.cmd :TestStrat))]
                                   [:D
                                    (fn []
                                      (vim.cmd :TestStop))]
                                   [:a
                                    (fn []
                                      (vim.cmd :TestAttach))]
                                   [:C
                                    (fn []
                                      (test_class))]
                                   [:m
                                    (fn []
                                      (test_method))]
                                   [:d
                                    (fn []
                                      (debug_selection))]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;;Overseer::My sweet beloved;;
(nyoom-module-p! overseer
                 (do
                   (local overseer-hints "
       Overseer
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
 _s_: OverseerRun
 _w_: OverseerToggle
 _d_: OverseerQuickAction
 _D_: OverseerTaskAction
 _b_: OverseerBuild
 _l_: OverseerLoadBundle
 _r_: OverseerRunCmd
 _t_: OverseerTemplate

    <Esc>: Quit
                          ")
                   (Hydra {:name :+Overseer
                           :hint overseer-hints
                           :config {:color :teal
                                    :invoke_on_body true
                                    :hint {:border :solid
                                           :position :middle-right}}
                           :mode [:n]
                           :body :<leader>l
                           :heads [[:w
                                    (fn []
                                      (vim.cmd :OverseerToggle))]
                                   [:s
                                    (fn []
                                      (vim.cmd :OverseerRun))]
                                   [:d
                                    (fn []
                                      (vim.cmd :OverseerQuickAction))]
                                   [:D
                                    (fn []
                                      (vim.cmd :OverseerTaskAction))]
                                   [:b
                                    (fn []
                                      (vim.cmd :OverseerBuild))]
                                   [:l
                                    (fn []
                                      (vim.cmd :OverseerLoadBundle))]
                                   [:r
                                    (fn []
                                      (vim.cmd :OverseerRunCmd))]
                                   [:t
                                    (fn []
                                      (let [overseer (require :overseer)
                                            command (.. "Run "
                                                        (vim.bo.filetype:gsub "^%l"
                                                                              string.upper)
                                                        " file ("
                                                        (vim.fn.expand "%:t")
                                                        ")")]
                                        (vim.notify command)
                                        (overseer.run_template {:name command}
                                                               (fn [task]
                                                                 (if task
                                                                     (overseer.run_action task
                                                                                          "open float")
                                                                     (vim.notify "Task not found"))))))]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Flash ;;
(nyoom-module-p! tree-sitter
                 (do
                   (local {: treejump : jump_window : win_select : tree_bounce}
                          (require :util))
                   (local flash-hints "
^^  - Mode
^^ _s_: Jump
^^ _S_: Treesitter
^^ _<c-s>_: Word Selection
^^ _r_: Remote
^^ _a_: Flash Line
^^ _w_: Flash Windows
^^ _W_: Flash Beginning words
^^ _M_: Flash Bounce
──────────────────────────
^^ _i_: SwapNode
^^ _h_: Swap Left
^^ _l_: Swap Right

^^ _<Esc>_: Escape")
                   (Hydra {:name :+flash
                           :hint flash-hints
                           :config {:color :teal
                                    :hint {:border :solid
                                           :position :middle-right}
                                    :invoke_on_body true}
                           :mode [:n]
                           :body :<leader>e
                           :heads [[:s
                                    (fn []
                                      ((. (require :flash) :jump)))]
                                   [:a
                                    (fn []
                                      ((. (require :flash) :jump) {:search {:mode :search}
                                                                   :highlight {:label {:after [0
                                                                                               0]}}
                                                                   :pattern "^"}))]
                                   [:w
                                    (fn []
                                      (jump_window))]
                                   [:<c-s>
                                    (fn []
                                      (win_select))
                                    {:desc "Select Any Word"}]
                                   [:W
                                    (fn []
                                      ((->> :jump
                                            (. (require :flash))) {:search {:mode (fn [str]
                                                                                      (.. "\\<"
                                                                                          str))}}))
                                    {:desc "Match beginning of words only"}]
                                   [:S
                                    (fn []
                                      ((. (require :flash) :treesitter)))]
                                   [:M
                                    (fn []
                                      (tree_bounce))
                                    {:desc "Flash TreeBounce"}]
                                   [:i
                                    (fn []
                                      #(vim.cmd :ISwapNodeWith))]
                                   [:r
                                    (fn []
                                      ((. (require :flash) :remote)))]
                                   [:R
                                    (fn []
                                      ((->> :treesitter_search
                                            (. (require :flash)))))]
                                   [:h #(vim.cmd :ISwapNodeWithRight)]
                                   [:l #(vim.cmd :ISwapNodeWithLeft)]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Neorg ;;
(nyoom-module-p! neorg
                 (do
                   (fn choose_workspace []
                     (vim.ui.select [:main
                                     :Math
                                     :NixOS
                                     :Chess
                                     :Programming
                                     :Academic_CS
                                     :Academic_Math]
                                    {:prompt "Select a workspace, slow bitch"
                                     :format_item (fn [item]
                                                    (.. "Neorg workspace " item))}
                                    (fn [choice]
                                      (vim.cmd (.. "Neorg workspace " choice)))))
                   (hydra-key! :n
                               {:ne {:hydra true
                                     :name :+Toggle
                                     :config {:color :pink
                                              :hint {:border :solid
                                                     :position :middle}
                                              :invoke_on_body true}
                                     :t [#(vim.cmd "Neorg journal today")
                                         "Journal Today"]
                                     :m [#(vim.cmd "Neorg journal tomorrow")
                                         "Journal Tomorrow"]
                                     :y [#(vim.cmd "Neorg journal yesterday")
                                         "Journal Yesterday"]
                                     :l [#(vim.cmd "Neorg toc right")
                                         "TOC Right"]
                                     :M [#(choose_workspace)
                                         "Workspace Choice"]
                                     :e [#(vim.cmd "Neorg inject-metadata")
                                         :inject-metadata]
                                     :i [#(vim.cmd "Neorg journal toc open")
                                         "Journal TOC Open"]}}
                               {:prefix :<leader>} 4)))

;; Gods given grace on earth ;;
(nyoom-module-p! telescope
                 (do
                   (local telescope-hint "
           _o_: old files   _g_: egrepify
           _p_: projects    _/_: search in file
           _r_: resume      _f_: find files
   ▁
           _h_: vim help    _c_: execute command
           _k_: keymaps     _;_: commands history
           _O_: options     _?_: search history
  ^
  _<Esc>_         _<Enter>_: NvimTree
    ")
                   (Hydra {:name :+file
                           :hint telescope-hint
                           :config {:color :teal
                                    :invoke_on_body true
                                    :hint {:position :middle :border :solid}}
                           :mode :n
                           :body :<Leader>t
                           :heads [[:f
                                    (fn []
                                      (vim.cmd.Telescope :find_files))]
                                   [:g
                                    (fn []
                                      (vim.cmd.Telescope :egrepify))]
                                   [:o
                                    (fn []
                                      (vim.cmd.Telescope :oldfiles))
                                    {:desc "recently opened files"}]
                                   [:h
                                    (fn []
                                      (vim.cmd.Telescope :help_tags))
                                    {:desc "vim help"}]
                                   [:k
                                    (fn []
                                      (vim.cmd.Telescope :keymaps))]
                                   [:O
                                    (fn []
                                      (vim.cmd.Telescope :vim_options))]
                                   [:r
                                    (fn []
                                      (vim.cmd.Telescope :resume))]
                                   [:p
                                    (fn []
                                      ((. (. (. (autoload :telescope)
                                                :extensions)
                                             :project)
                                          :project) {:display_type :full}))
                                    {:desc :projects}]
                                   ["/"
                                    (fn []
                                      (vim.cmd.Telescope :current_buffer_fuzzy_find))
                                    {:desc "search in file"}]
                                   ["?"
                                    (fn []
                                      (vim.cmd.Telescope :search_history))
                                    {:desc "search history"}]
                                   [";"
                                    (fn []
                                      (vim.cmd.Telescope :command_history))
                                    {:desc "command-line history"}]
                                   [:c
                                    (fn []
                                      (vim.cmd.Telescope :commands))
                                    {:desc "execute command"}]
                                   [:<Enter>
                                    (fn []
                                      (vim.cmd :NvimTreeToggle))
                                    {:exit true :desc :NvimTree}]
                                   [:<Esc> nil {:exit true :nowait true}]]})))

;; Debugger ;;
(nyoom-module-p! debugger
                 (do
                   (local dap (autoload :dap))
                   (local ui (autoload :dapui))
                   (local hint "
                 Debug
      ^ ^Step^ ^ ^     ^ ^     Action
      ^ ^ ^ ^ ^ ^      ^ ^
      ^ ^back^ ^ ^     ^_t_ toggle breakpoint
      ^ ^ _K_^ ^        _T_ clear breakpoints
  out _H_ ^ ^ _L_ into  _c_ continue
      ^ ^ _J_ ^ ^       _x_ terminate
      ^ ^over ^ ^     ^^_r_ open repl
      ^
  _<Esc>_               _<Enter>_: DapUI
")
                   (Hydra {:name :+debug
                           : hint
                           :config {:color :pink
                                    :invoke_on_body true
                                    :hint {:border :solid :position :middle}}
                           :mode [:n]
                           :body :<leader>d
                           :heads [[:H dap.step_out {:desc "step out"}]
                                   [:J dap.step_over {:desc "step over"}]
                                   [:K dap.step_back {:desc "step back"}]
                                   [:L dap.step_into {:desc "step into"}]
                                   [:t
                                    dap.toggle_breakpoint
                                    {:desc "toggle breakpoint"}]
                                   [:T
                                    dap.clear_breakpoints
                                    {:desc "clear breakpoints"}]
                                   [:c dap.continue {:desc :continue}]
                                   [:x dap.terminate {:desc :terminate}]
                                   [:r
                                    dap.repl.open
                                    {:exit true :desc "open repl"}]
                                   [:<Esc> nil {:exit true :nowait true}]
                                   [:<Enter>
                                    (fn []
                                      (ui.toggle))]]})))

;; LSP Utilities ;;
(nyoom-module-p! lsp (do
                       (hydra-key! :n
                                   {:cl {:hydra true
                                         :name :+LSP
                                         :config {:color :pink
                                                  :hint {:border :solid
                                                         :position :bottom-middle}
                                                  :invoke_on_body true}
                                         :s [#(vim.cmd "Lspsaga hover_doc")
                                             "+ HoverDocs"]
                                         :S [#(vim.cmd "Lspsaga peek_definition")
                                             "+ PeekDefinition"]
                                         :m [#(vim.cmd "Lspsaga peek_type_definition")
                                             "+ PeekTypeDefinition"]
                                         :M [#(vim.cmd :Navbuddy) "+ Navbuddy"]
                                         :t [#(vim.cmd "Lspsaga outline")
                                             "+ Outline"]
                                         :L [#(vim.cmd :LspLensOn) "+ LspLens"]}}
                                   {:prefix :<leader>} 4)))

;; Rusty tools for rusty mans ;;
(nyoom-module-p! rust
                 (do
                   (fn rust-hydra []
                     (hydra-key! :n
                                 {:m {:hydra true
                                      :name "  Rust"
                                      :config {:color :teal
                                               :invoke_on_body true
                                               :hint {:position :middle
                                                      :border :solid}}
                                      :c [#(vim.cmd "RustLsp codeAction")
                                          "Rust codeAction"]
                                      :C [#(vim.cmd "RustLsp crateGraph")
                                          "Rust crateGraph"]
                                      :d [#(vim.cmd "RustLsp debuggables")
                                          "Rust debuggables"]
                                      :e [#(vim.cmd "RustLsp expandMacro")
                                          "Rust expandMacro"]
                                      :D [#(vim.cmd "RustLsp externalDocs")
                                          "Rust externalDocs"]
                                      :h [#(vim.cmd "RustLsp hover range")
                                          "Rust hover"]
                                      :r [#(vim.cmd "RustLsp runnables")
                                          "Rust runnables"]
                                      :l [#(vim.cmd "RustLsp joinLines")
                                          "Rust joinLines"]
                                      :m [#(vim.cmd "RustLsp moveItem")
                                          "Rust moveItem"]
                                      :o [#(vim.cmd "RustLsp openCargo")
                                          "Rust openCargo"]
                                      :p [#(vim.cmd "RustLsp parentModule")
                                          "Rust parentModule"]
                                      :s [#(vim.cmd "RustLsp ssr") "Rust ssr"]
                                      :w [#(vim.cmd "RustLsp reloadWorkspace")
                                          "Rust reloadWorkspace"]
                                      :S [#(vim.cmd "RustLsp syntaxTree")
                                          "Rust syntaxTree"]
                                      :f [#(vim.cmd "RustLsp flyCheck")
                                          "Rust flyCheck"]}}
                                 {:prefix :<leader>}))
                   (augroup! localleader-hydras
                             (autocmd! FileType rust `(rust-hydra)))))

;;TODO:: add more utilities and tinker with HT
(nyoom-module-p! animate
                 (do
                   (local venv-hints "
Venv:Mode
Arrow^^^^^^  Select region with <C-v>^^^^^^
^ ^ _K_ ^ ^  _f_: Surround with box ^ ^ ^ ^
_H_ ^ ^ _L_  _<C-h>_: ◄, _<C-j>_: ▼
^ ^ _J_ ^ ^  _<C-k>_: ▲, _<C-l>_: ► _<C-c>_
      ")
                   (Hydra {:name "Draw Diagrams"
                           :hint venv-hints
                           :config {:color :pink
                                    :invoke_on_body true
                                    :hint {:border :rounded}
                                    :on_enter (fn []
                                                (set vim.wo.virtualedit :all))}
                           :mode [:n]
                           :body :<leader>w
                           :heads [[:<C-h> :xi<C-v>u25c4<Esc>]
                                   [:<C-j> :xi<C-v>u25bc<Esc>]
                                   [:<C-k> :xi<C-v>u25b2<Esc>]
                                   [:<C-l> :xi<C-v>u25ba<Esc>]
                                   [:H "<C-v>h:VBox<CR>"]
                                   [:J "<C-v>j:VBox<CR>"]
                                   [:K "<C-v>k:VBox<CR>"]
                                   [:L "<C-v>l:VBox<CR>"]
                                   [:f ":VBox<CR>" {:mode :v}]
                                   [:<C-c> nil {:exit true}]]})))

;; Haskell ;;
(nyoom-module-p! haskell
                 (do
                   (local haskell-tools (autoload :haskell-tools))
                   (local project (autoload :haskell-tools.project))
                   (local hoogle (autoload :haskell-tools.hoogle))
                   (fn haskell-hydra []
                     (hydra-key! :n
                                 {:H {:hydra true
                                      :name :+Haskell-Tools
                                      :config {:color :teal
                                               :hint {:border :solid
                                                      :position :bottom-middle}
                                               :invoke_on_body true}
                                      :s [#(vim.cmd :HSProjectFile)
                                          "Open Project-File"]
                                      :S [#(vim.cmd :HsPackageYaml)
                                          "Open package.yaml"]
                                      :m [#(vim.cmd :HsPackageCabal)
                                          "Open *.cabal"]
                                      :M [#((. project :telescope_package_grep))
                                          "Telescope Packages"]
                                      :t [#((. hoogle :hoogle_signature) (vim.api.nvim_get_current_line))
                                          "Hoogle search Line"]}}
                                 {:prefix :<leader>} 4))

                   (augroup! localleader-hydras
                             (autocmd! FileType haskell `(haskell-hydra)))))

;; Go faster, wagie! ;;
; (nyoom-module-p! go
;                  (do
;                    (fn go-hydra []
;                      (hydra-key! :n
;                         {:G {:hydra true
;                              :name "Go:: Coding"
;                              :config {:color :teal
;                                       :hint {:border :solid
;                                              :position :middle-right}
;                                       :invoke_on_body true}
;                              :a [#(vim.cmd :GoCodeAction) "Add tags"]
;                              :e [#(vim.cmd :GoIfErr) "Add if err"]
;                              :i [#(vim.cmd :GoToggleInlay)
;                                  "Toggle inlay"]
;                              :l [#(vim.cmd :GoLint) "Run linter"]
;                              :o [#(vim.cmd :GoPkgOutline) :Outline]
;                              :r [#(vim.cmd :GoRun) :Run]
;                              :s [#(vim.cmd :GoFillStruct)
;                                  "Autofill struct"
;                                  {:prefix :<leader>} 1]}})
;                      (hydra-key! :n
;                             {:fh {:name "Go:: Helpers"
;                                   :a [#(vim.cmd :GoAddTag)
;                                       "Add tags to struct"]
;                                   :r [#(vim.cmd :GoRMTag)
;                                       "Remove tags to struct"]
;                                   :c [#(vim.cmd :GoCoverage)
;                                       "Test coverage"]
;                                   :g [#(vim.cmd "lua require('go.comment').gen()")
;                                       "Generate comment"]
;                                   :v [#(vim.cmd :GoVet) "Go vet"]
;                                   :t [#(vim.cmd :GoModTidy) "Go mod tidy"]
;                                   :i [#(vim.cmd :GoModInit) "Go mod init"]}}
;                             {:prefix :<leader>})
;                      (hydra-key! :n
;                                  {:ft {:name "Go:: Tests"
;                                        :r [#(vim.cmd :GoTest) "Run tests"]
;                                        :a [#(vim.cmd :GoAlt!) "Open alt file"]
;                                        :s [#(vim.cmd :GoAltS!)
;                                            "Open alt file in split"]
;                                        :v [#(vim.cmd :GoAltV!)
;                                            "Open alt file in vertical split"]
;                                        :u [#(vim.cmd :GoTestFunc)
;                                            "Run test for current func"]
;                                        :f [#(vim.cmd :GoTestFile)
;                                            "Run test for current file"]}}
;                                  {:prefix :<leader>})
;                      (hydra-key! :n
;                                  {:fx {:name "Go:: Codelens"
;                                        :l [#(vim.cmd :GoCodeLenAct)
;                                            "Toggle Lens"]
;                                        :a [#(vim.cmd :GoCodeAction)
;                                            "Code Action"]}}
;                                  {:prefix :<leader>}))
;                    (augroup! localleader-hydras
;                              (autocmd! FileType go `(go-hydra)))))
;
;Intercourse;;
(nyoom-module-p! latex
                 (do
                   (fn latex-hydra []
                     (local vimtex-hint "
    ^                     VimTex
    ^
    _ll_: Continuous Compile    _ss_: Snapshot Compile
    _lC_: Clean Up Files        _lt_: Table of Content
    _cw_: Count Words           _cl_: Count Letters
    _le_: Errors                _lq_: Log
    ^
    ^_h_: Default Maps                      _<Esc>_^^^
       ")
                     (Hydra {:name :+latex
                             :hint vimtex-hint
                             :config {:color :amaranth
                                      :invoke_on_body true
                                      :hint {:border :solid :position :middle}
                                      :buffer true}
                             :mode [:n :x]
                             :body :<leader>F
                             :heads [[:ll
                                      (fn []
                                        (vim.cmd :VimtexCompile))
                                      {:exit true}]
                                     [:ss
                                      (fn []
                                        (vim.cmd :VimtexCompileSS))
                                      {:exit true}]
                                     [:lC
                                      (fn []
                                        (vim.cmd :VimtexClean!))
                                      {:exit true}]
                                     [:cw
                                      (fn []
                                        (vim.cmd :VimtexCountWords))
                                      {:exit true}]
                                     [:cl
                                      (fn []
                                        (vim.cmd :VimtexCountLetters))
                                      {:exit true}]
                                     [:le
                                      (fn []
                                        (vim.cmd :VimtexErrors))
                                      {:exit true}]
                                     [:lt
                                      (fn []
                                        (vim.cmd :VimtexTocToggle))
                                      {:exit true}]
                                     [:lq
                                      (fn []
                                        (vim.cmd :VimtexLog))
                                      {:exit true}]
                                     [:h
                                      (fn []
                                        (vim.cmd "h vimtex-mefault-mappings"))
                                      {:exit true}]
                                     [:td
                                      (fn []
                                        vim.cmd
                                        "TSDisable highlights")]
                                     [:<Esc> nil {:exit true :nowait true}]]}))
                   (augroup! localleader-hydras
                             (autocmd! FileType tex `(latex-hydra)))))
