(import-macros {: set!
                : colorscheme
                : nyoom-module-p!
                : augroup!
                : autocmd!
                : packadd!} :macros)

(local {: hydra-key!} (require :util.hydra))
(local Hydra (autoload :hydra))
(local {: trigger_load} (autoload :lz.n))
(local theme (. (require :util.color) :carbonfox))

(vim.api.nvim_set_hl 0 :HydraRed theme.hydra.red)
(vim.api.nvim_set_hl 0 :HydraBlue theme.hydra.blue)
(vim.api.nvim_set_hl 0 :HydraAmaranth theme.hydra.amaranth)
(vim.api.nvim_set_hl 0 :HydraTeal theme.hydra.teal)
(vim.api.nvim_set_hl 0 :HydraPink theme.hydra.pink)
(vim.api.nvim_set_hl 0 :HydraHint theme.fancy_float.window)
(vim.api.nvim_set_hl 0 :HydraBorder theme.fancy_float.border)
(vim.api.nvim_set_hl 0 :HydraTitle theme.fancy_float.title)
(vim.api.nvim_set_hl 0 :HydraFooter theme.fancy_float.title)

;; fnlfmt: skip
;; NOTE:: The formatter will butcher this file, donnot, under any circumstance, remove this!

;; TO METATABLE, with `__index` taking a `name` and opts.
(local hIndex {})
(tset hIndex :HermitAge
      (Hydra {:name "[Hy]dra [Con]troller"
              :hint "
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
    _d_ [D]AP^^
    _r_ [Re]pl^^
    _t_ [Tel]escope ^^
    _u_ [Neo]Test ^^
    _o_ [O]verseer ^^
    _<C-o>_ [O]cto ^^
    _g_ [G]it ^^
    _l_ [L]sp ^^
    _v_: [O]ption ^^
    _q_/_;_: Leave

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               "
              :mode [:n :v :x :o]
              :body ";;"
              :config {:color :pink
                       :invoke_on_body true
                       :hint {:type :window
                              :float_opts {:style :minimal :noautocmd false}
                              :position :bottom-right}}
              :heads [[:g
                       #(: hIndex.Git :activate)
                       {:desc "[G]it" :nowait true}]
                      [:o
                       #(: hIndex.overseer :activate)
                       {:desc "[Ov]erseer" :nowait true}]
                      [:t
                       #(: hIndex.telescope :activate)
                       {:desc "[Te]le" :nowait true}]
                      [:u #(: hIndex.neotest :activate)]
                      [:v #(: hIndex.options :activate) {:nowait true}]
                      [:<C-o> #(: hIndex.octo :activate) {:nowait true}]
                      [:r #(print :hello) {:desc "[R]epl"}]
                      [:d #(print :hello) {:desc "[R]epl"}]
                      [:l #(print :hello) {:desc "[R]epl"}]
                      [";" nil {:exit true :nowait true}]
                      [:q nil {:exit true}]]}))

(nyoom-module-p! vc-gutter
                 (do
                   (trigger_load :gitsigns)
                   (local {: toggle_linehl
                           : toggle_deleted
                           : toggle_signs
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

    ^^_J_: next hunk     _d_: show deleted  ^^
    ^^_K_: prev hunk     _u_: undo last stage ^^
    ^^_s_: stage hunk    _B_: blame show full ^^
    ^^_p_: preview hunk  _S_: stage buffer  ^^
    ^^_b_: blame Line    _<CR>_: Neogit     ^^

    ^^ _;_: [He]rmitAge ^^  _<Esc>_: Exit
      ")
                   (tset hIndex :Git
                         (Hydra {:name "[Hy]dra [G]it"
                                 :hint git-hint
                                 :mode [:n :v :x :o]
                                 :body ";g"
                                 :config {:color :pink
                                          :invoke_on_body true
                                          :on_key #(vim.wait 50)
                                          :on_exit (fn []
                                                     (local cursor-pos
                                                            (vim.api.nvim_win_get_cursor 0))
                                                     (vim.cmd.loadview)
                                                     (vim.api.nvim_win_set_cursor 0
                                                                                  cursor-pos)
                                                     (vim.cmd.normal :zv)
                                                     (toggle_linehl false)
                                                     (toggle_signs true)
                                                     (toggle_deleted false))
                                          :on_enter (fn []
                                                      (vim.cmd.mkview)
                                                      (vim.cmd "silent! %foldopen!")
                                                      (toggle_linehl true)
                                                      (toggle_deleted true)
                                                      (toggle_signs true))
                                          :hint {:type :window
                                                 :float_opts {:style :minimal
                                                              :noautocmd false}
                                                 :position :middle}}
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
                                                  (vim.api.nvim_feedkeys esc :x
                                                                         false)
                                                  (vim.cmd "'<,'>Gitsigns stage_hunk"))
                                                (vim.cmd.Gitsigns :stage_hunk)))
                                          {:desc "stage hunk"}]
                                         [:u
                                          undo_stage_hunk
                                          {:desc "undo last stage"}]
                                         [:S
                                          stage_buffer
                                          {:desc "stage buffer"}]
                                         [:p
                                          preview_hunk
                                          {:desc "preview hunk"}]
                                         [:d
                                          toggle_deleted
                                          {:nowait true :desc "toggle deleted"}]
                                         [:b blame_line {:desc :blame}]
                                         [:B
                                          (fn []
                                            blame_line
                                            {:full true})
                                          {:desc "blame show full"}]
                                         [:<CR>
                                          (vim.schedule_wrap #(vim.cmd :Neogit))
                                          {:exit true :desc :Neogit}]
                                         [";"
                                          #(: hIndex.HermitAge :activate)
                                          {:exit true :nowait true}]
                                         [:<Esc> nil {:exit true :nowait true}]]}))))

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
    _;_: HermitAge^^
         ^^^^              _<Esc>_
    ")
                   (tset hIndex :options
                         (Hydra {:name :+options
                                 :hint options-hint
                                 :config {:color :pink
                                          :invoke_on_body true
                                          :hint {:type :window
                                                 :float_opts {:style :minimal
                                                              :noautocmd true}
                                                 :position :middle
                                                 :show_name true}}
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
                                         [";"
                                          #(: hIndex.HermitAge :activate)
                                          {:exit true :nowait true}]
                                         [:<Esc> nil {:exit true :nowait true}]]}))))

;; Octussy ;;
(nyoom-module-p! octo
                 (do
                   (local {: caller} (require :util.octo))
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
^▔▔▔▔▔▔▔▔▔▔▔^
^_;_: HermitAge
^ <Esc>: Quit
^▔▔▔▔▔▔▔▔▔▔▔^
    ")
                   (tset hIndex :octo
                         (Hydra {:name :+Octo
                                 :hint octo-hints
                                 :config {:color :red
                                          :invoke_on_body true
                                          :on_enter #(trigger_load :octo)
                                          :hint {:type :window
                                                 :float_opts {:style :minimal
                                                              :noautocmd true}
                                                 :position :middle-right
                                                 :show_name true}}
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
                                                   [:list
                                                    :fork
                                                    :browser
                                                    :url
                                                    :view])
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
                                            (caller [:resolve :unresolve]
                                                    :threat))
                                          {:exit true}]
                                         [:l
                                          (fn []
                                            (local options
                                                   [:add "remove:" :create])
                                            (caller options :label))
                                          {:exit true}]
                                         ["-"
                                          (fn []
                                            (local options
                                                   [:thumbs_up
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
                                         [";"
                                          #(: hIndex.HermitAge :activate)
                                          {:exit true :nowait true}]
                                         [:<Esc> nil {:exit true :nowait true}]]}))))

;; Neotest ;;

;; fnlfmt: skip
(nyoom-module-p! neotest
            (hydra-key! :n
                        {:u {:hydra true
                             :name :+Neotest
                             :config {:color :pink
                                      :invoke_on_body true
                                      :on_enter #(trigger_load :neotest)
                                      :hint {:type :window
                                             :float_opts {:style :minimal}
                                             :show_name true
                                             :position :bottom-middle}}
                             :<CR> [#((->> :run
                                           (. (require :neotest)
                                              :run)) (vim.fn.expand "%"))
                                    "[R]un Current File"]
                             :c [#((->> :run
                                        (. (require :neotest) :run)) (vim.fn.expand "%"))
                                 "[R]un File"]
                             :o [#((->> :open
                                        (. (require :neotest) :output)) {:enter true})
                                 "[O]utput Open"]
                             :s [#((->> :toggle
                                        (. (require :neotest) :summary)))
                                 "[T]oggle Summary"]
                             :S [(fn [arg]
                                   (let [options [:dap :integrated]]
                                        (match (vim.tbl_contains options
                                                                 arg.arg)
                                          (where k1 (= k1 true)) ((->> :run
                                                                       (. (require :neotest)
                                                                          :run)) {:strategy arg.arg})
                                          (where k2 (= k2 false)) ((->> :run
                                                                        (. (require :neotest)
                                                                           :run)) {:strategy :integrated}))))
                                 "[T]est integrated"]
                             :D [#((->> :stop
                                        (. (require :neotest) :run)))
                                 "[S]top Runner"]
                             :a [#((->> :attach
                                        (. (require :neotest) :run)))
                                 "[R]un Attach"]
                             :C [#(when (= vim.bo.filetype :python)
                                    ((. (require :dap-python) :test_class))) "[Py] [T]est Class"]
                             :m [#(when (= vim.bo.filetype :python)
                                   ((. (require :dap-python) :test_method))) "[Py] [T]est Method"]
                             :d [#(when (= vim.bo.filetype :python)
                                    ((. (require :dap-python) :debug_selection))) "[Py] [D]ebug Visual"]}}
                        {:prefix :<leader>} 1))

;;Overseer ;;
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
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
_<Esc>_: Quit
_;_: [He]rmitage
                          ")
                   (tset hIndex :overseer
                         (Hydra {:name "[Hy]dra:: [Ov]erseer"
                                 :hint overseer-hints
                                 :config {:color :pink
                                          :on_enter #(trigger_load :overseer)
                                          :invoke_on_body true
                                          :hint {:border :solid
                                                 :position :middle-right}}
                                 :mode [:n]
                                 :body :<space>l
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
                                            (let [overseer (require :overseer)]
                                              command
                                              (.. "Run "
                                                  (vim.bo.filetype:gsub "^%l"
                                                                        string.upper)
                                                  " file ("
                                                  (vim.fn.expand "%:t") ")")
                                              (vim.notify command)
                                              (overseer.run_template {:name command}
                                                                     (fn [task]
                                                                       (if task
                                                                           (overseer.run_action task
                                                                                                "open float")
                                                                           (vim.notify "Task not found"))))))]
                                         [";"
                                          #(: hIndex.HermitAge :activate)
                                          {:exit true :nowait true}]
                                         [:<Esc> nil {:exit true :nowait true}]]}))))

;; Flash ;;
(nyoom-module-p! tree-sitter
                 (do
                   (local {: treejump : jump_window : win_select : tree_bounce}
                          (require :util))
                   (local flash-hints "
^^  - Mode
──────────────────────────
^^ _s_: Jump
^^ _S_: Treesitter
^^ _<c-s>_: Word Selection
^^ _r_: Remote
^^ _a_: Flash Line
^^ _w_: Flash Windows
^^ _M_: Flash Bounce
^^ _R_: Flash TS remote

^^ _<Esc>_: Escape")
                   (Hydra {:name "[Hy]dra [Fl]ash"
                           :hint flash-hints
                           :config {:color :pink
                                    :hint {:type :window
                                           :float_opts {:style :minimal
                                                        :noautocmd true}
                                           :show_name true
                                           :position :middle-right}
                                    :invoke_on_body true}
                           :mode [:n]
                           :body ";e"
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
                                   [:S
                                    (fn []
                                      ((. (require :flash) :treesitter)))]
                                   [:M
                                    (fn []
                                      (tree_bounce))
                                    {:desc "Flash TreeBounce"}]
                                   [:r
                                    (fn []
                                      ((. (require :flash) :remote)))]
                                   [:R
                                    (fn []
                                      ((->> :treesitter_search
                                            (. (require :flash)))))]
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
                                                    (.. "WorkSpace:: " item))}
                                    (fn [choice]
                                      (vim.cmd (.. "Neorg workspace " choice)))))
                   (hydra-key! :n
                               {:ne {:hydra true
                                     :name "[Hy]dra [Ne]org"
                                     :config {:color :pink
                                              :invoke_on_body true
                                              :hint {:type :window
                                                     :float_opts {:style :minimal
                                                                  :noautocmd true}
                                                     :show_name true
                                                     :position :middle}}
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

;; fnlfmt: skip
(nyoom-module-p! telescope
                 (do
                   (local telescope-hint "
           _o_: old files   _g_: egrepify^^
           _p_: projects    _/_: search in file^^
           _r_: resume      _f_: find files^^
   ▁
           _h_: vim help    _c_: execute command^^
           _k_: keymaps     _C_: commands history^^
           _O_: options     _?_: search history^^

           _<Esc>_: exit  _<leader>_: [O]il^^
                    _;_: HermitAge^^
                ")
                   (tset hIndex :telescope (Hydra {:name "[Hy]dra [Tele]scope"
                                                      :hint telescope-hint
                                                      :config {:color :pink
                                                               :on_enter #(trigger_load :telescope)
                                                               :invoke_on_body true
                                                               :hint {:type :window
                                                                      :offset 1
                                                                      :float_opts {:style :minimal
                                                                                   :noautocmd true}
                                                                      :position :middle}}
                                                      :mode :n
                                                      :body ";t"
                                                      :heads [[:f
                                                               (fn []
                                                                 (vim.cmd.Telescope :find_files))]
                                                              [:g
                                                               (fn []
                                                                 ((. (autoload :telescope) :extensions
                                                                     :egrepify :egrepify) ((->> :get_ivy
                                                                                            (. (autoload :telescope.themes))) {})))]
                                                              [:o
                                                               (fn []
                                                                 (vim.cmd.Telescope :oldfiles))
                                                               {:desc "recently opened files"}]
                                                              [:h
                                                               (fn []
                                                                 ((. (autoload :telescope.builtin) :help_tags) ((. (autoload :telescope.themes) :get_ivy))))
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
                                                                 #(vim.cmd.Telescope :current_buffer_fuzzy_find)
                                                               {:desc "search in file"}]
                                                              ["?"
                                                                 #(vim.cmd.Telescope :search_history)
                                                               {:desc "search history"}]
                                                              ["C"
                                                                 #(vim.cmd.Telescope :command_history)
                                                               {:desc "command-line history"}]
                                                              [:c
                                                                 #(vim.cmd.Telescope :commands)
                                                               {:desc "execute command"}]
                                                              [:<leader>
                                                                 #(vim.cmd.Oil)
                                                               {:exit true :desc :Oil}]
                                                              [";" #(: hIndex.HermitAge :activate) {:exit true :nowait true}]
                                                              [:<Esc> nil {:exit true :nowait true}]]}))))

;; Debugger ;;
(nyoom-module-p! debug
                 (do
                   (let [dap (autoload :dap)
                         ui (autoload :dapui)]
                     (hydra-key! :n
                                 {:d {:hydra true
                                      :name " Debug"
                                      :config {:color :pink
                                               :invoke_on_body true
                                               :on_enter #(trigger_load :dap)
                                               :hint {:type :window
                                                      :offset 1
                                                      :float_opts {:style :minimal
                                                                   :noautocmd false}
                                                      :position :bottom-middle}}
                                      :H [#(dap.step_out) "[s]out"]
                                      :J [#(dap.step_over) "[s]over"]
                                      :K [#(dap.step_back) "[s]back"]
                                      :L [#(dap.step_into) "[s]into"]
                                      :t [#(dap.toggle_breakpoint)
                                          "[Tog]BreakPt"]
                                      :T [#(dap.clear_breakpoints)
                                          "[Clr]BreakPt"]
                                      :c [#(dap.continue) "[D]Continue"]
                                      :x [#(dap.terminate) "[D]Stop"]
                                      :r [#(dap.repl) "[D]Repl"]
                                      :<Enter> [#(ui.toggle) "[UI] Toggle"]}}
                                 {:prefix :<leader>} 4))))

;; LSP Utilities ;;
(nyoom-module-p! lsp (do
                       (hydra-key! :n
                                   {:cl {:hydra true
                                         :name :+LSP
                                         :config {:on_enter #(trigger_load :lspsaga)
                                                  :color :pink
                                                  :hint {:border :solid
                                                         :position :bottom-middle}
                                                  :invoke_on_body true}
                                         :s [#(vim.cmd "Lspsaga hover_doc")
                                             "+ HoverDocs"]
                                         :S [#(vim.cmd "Lspsaga peek_definition")
                                             "+ PeekDefinition"]
                                         :m [#(vim.cmd "Lspsaga peek_type_definition")
                                             "+ PeekTypeDefinition"]
                                         :t [#(vim.cmd "Lspsaga outline")
                                             "+ Outline"]
                                         :L [#(vim.cmd :LspLensOn) "+ LspLens"]}}
                                   {:prefix :<leader>} 4)))

;; Rusty tools for rusty mans ;;

(tset hIndex :Crates (Hydra {:name "[Cr]ates [Hy]dra"
                             :config {:color :pink
                                      :hint {:type :window
                                             :position :middle-right}}
                             :heads [[:p #(vim.cmd "Crates show_popup")]
                                     [:d
                                      #(vim.cmd "Crates show_dependencies_popup")
                                      {:desc "[C]rates [D]eps"}]
                                     [:g
                                      #(vim.cmd "Crates use_git_source")
                                      {:desc "[C]rates [U]se Git"}]
                                     [:f
                                      #(vim.cmd "Crates show_features_popup")
                                      {:desc "[C]rates [F]eatures"}]
                                     [";"
                                      #(: hIndex.rustAge :activate)
                                      {:exit true
                                       :nowait true
                                       :desc "[He]rmitAge"}]]}))
                                     

(nyoom-module-p! rust (hydra-key! :n
                                  {:cm {:hydra true
                                        :name "[Hy]dra [R]ust::  "
                                        :config {:color :pink
                                                 :invoke_on_body true
                                                 :hint {:type :window
                                                        :position :bottom-middle}}
                                        :c [#(vim.cmd "RustLsp codeAction")
                                            "[C]Action"]
                                        :C [#(vim.cmd "RustLsp crateGraph")
                                            "[CR]Graph"]
                                        :d [#(vim.cmd "RustLsp debuggables")
                                            "[R]debuggables"]
                                        :e [#(vim.cmd "RustLsp expandMacro")
                                            "[R]expandMacro"]
                                        :D [#(vim.cmd "RustLsp externalDocs")
                                            "[R]externalDocs"]
                                        :h [#(vim.cmd "RustLsp hover range")
                                            "[R]hover"]
                                        :r [#(vim.cmd "RustLsp runnables")
                                            "[R]runnables"]
                                        :l [#(vim.cmd "RustLsp joinLines")
                                            "[R]joinLines"]
                                        :m [#(vim.cmd "RustLsp moveItem")
                                            "[R]moveItem"]
                                        :o [#(vim.cmd "RustLsp openCargo")
                                            "[Ro]Cargo"]
                                        :p [#(vim.cmd "RustLsp parentModule")
                                            "[R][P]Module"]
                                        ";" [#(: hIndex.Crates :activate)
                                             "[C]rates [Hydra]"]
                                        :s [#(vim.cmd "RustLsp ssr") "[R]ssr"]
                                        :w [#(vim.cmd "RustLsp reloadWorkspace")
                                            "[Rl]lsp-Reload"]
                                        :S [#(vim.cmd "RustLsp syntaxTree")
                                            "[R]syncTree"]
                                        :f [#(vim.cmd "RustLsp flyCheck")
                                            "[R]flyCheck"]
                                        :<Esc> [#(print :Exiting) :Exit true]}}
                                  {:prefix :<leader>} 4))

;
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

;;TODO:: add more utilities and tinker with HT
;; Haskell ;;
(nyoom-module-p! haskell
                 (let [ht (autoload :haskell-tools)
                       project (autoload :haskell-tools.project)
                       hoogle (autoload :haskell-tools.hoogle)]
                   (hydra-key! :n
                               {:h {:hydra true
                                    :name "+Hydra::Haskell"
                                    :config {:color :pink
                                             :hint {:type :window
                                                    :offset 1
                                                    :float_opts {:style :minimal
                                                                 :noautocmd false}
                                                    :position :bottom-middle}
                                             :invoke_on_body true}
                                    :f [#(vim.cmd :HSProjectFile)
                                        "[O]pen *.project"]
                                    :S [#(vim.cmd :HsPackageYaml)
                                        "[O]pen [Y]aml"]
                                    :h [#(vim.cmd "Telescope hoogle")
                                        "[T]ele [H]oogle"]
                                    :m [#(vim.cmd :HsPackageCabal)
                                        "[O]pen [C]abal"]
                                    :M [#((. project :telescope_package_grep))
                                        "[T]ele [P]ack"]
                                    :w [#(ht.repl.cword_type)
                                        "[R]epl [P] <Cword>"]
                                    :r [#(ht.repl.toggle) "[R]epl [T]oggle"]
                                    :s [#(ht.repl.reload) "[R]epl [R]eload"]
                                    :t [#(ht.repl.paste_type) "[R]epl [P]aste"]
                                    :u [#(ht.repl.toggle (vim.api.nvim_buf_get_name (vim.api.nvim_get_current_buf)))
                                        "[R]epl [P] Buffer"]
                                    :q [#(ht.repl.quit) "[R]epl [Q]uit"]}}
                               {:prefix ";"} 4)))

;; fnlfmt: skip
(nyoom-module-p! harpoon
                 (do
                   (let [harpoon (autoload :harpoon)
                         _harpNS #(vim.api.nvim_create_namespace :harpoon_sign)
                         _harpSign (fn [row]
                                     (vim.api.nvim_buf_set_extmark 0 (_harpNS) (- row 1) -1 {:sign_text " "
                                                                                             :sign_hl_group :HarpSgn}))
                         _harpAdd (fn []
                                    (vim.api.nvim_buf_clear_namespace 0 (_harpNS) 0 -1)
                                    (_harpSign (vim.fn.line "."))
                                    (: (: harpoon :list) :add))]
                    (hydra-key! :n
                                {:a {:hydra true
                                     :name "+Hydra::Harpoon"
                                     :config {:color :pink
                                              :hint {:border :solid
                                                     :position :bottom-middle}
                                              :on_enter #(do
                                                           (vim.api.nvim_set_hl 0 "HarpSgn" {:fg "#8aadf4" :bold true})
                                                           (trigger_load :harpoon))
                                              :invoke_on_body true}
                                     :A [#(_harpAdd) "[A]dd [F]tag"]
                                     :p [#(-> harpoon (: :list) (: :prev)) :Prev]
                                     :n [#(-> harpoon (: :list) (: :next)) :Next]
                                     :a [#(-> harpoon (: :list) (: :add))
                                         "[A]dd [F]ile"]
                                     :s [#(: (. harpoon :ui) :toggle_quick_menu (: harpoon :list "oqt"))
                                          "[OS] [L]task"]
                                     :S [#((. (require "oqt") :prompt_new_task))
                                         "[OS] [N]task"]
                                     :<CR> [#(: (. harpoon :ui) :toggle_quick_menu (: harpoon :list)) "[Q]uick [M]enu"]}}
                                {:prefix :<leader>} 4))))

;; TODO:: Make SubHydras For Swapping and Node Selection

;; fnlfmt: skip
(nyoom-module-p! swap (hydra-key! :n
                                  {:s {:hydra true
                                       :name "[Hy]dra [S]wap"
                                       :config {:color :blue
                                                :invoke_on_body true
                                                :hint {:type :window
                                                       :offset 0
                                                       :float_opts {:style :minimal
                                                                    :noautocmd false}
                                                       :position :bottom-middle
                                                       :show_name true}}
                                       :k [(fn []
                                             ((->> :swap_next
                                                   (. (require :nvim-treesitter.textobjects.swap))) "@parameter.inner"))
                                           "[N] @Inner"]
                                       :j [(fn []
                                             ((->> :swap_previous
                                                   (. (require :nvim-treesitter.textobjects.swap))) "@parameter.inner"))
                                           "[P] @Inner"]
                                       :s [#(vim.cmd :ISwap) :ISwap]
                                       :S [#(vim.cmd :ISwapWith) :ISwapWith]
                                       :w [(fn []
                                             ((->> :go_to_top_node_and_execute_commands
                                                   (. (require :syntax-tree-surfer))) false
                                                    ["normal! O"
                                                     "normal! O"
                                                     :startinsert]))
                                           "Edit::[T]Node"]
                                       :n [#(vim.cmd :STSSelectMasterNode)
                                           "STS::[Cr]Node"]
                                       :N [#(vim.cmd :STSSelectCurrentNode)
                                           "STS::[Ms]Node"]
                                       :H [#(vim.cmd :STSSelectNextSiblingNode)
                                           "STS::[N]Sibling"]
                                       :J [#(vim.cmd :STSSelectPrevSiblingNode)
                                           "STS::[P]Sibling"]
                                       :K [#(vim.cmd :STSSelectParentNode)
                                           "STS::[P]node"]
                                       :L [#(vim.cmd :STSSelectChildNode)
                                           "STS::[C]Node"]
                                       :v [#(vim.cmd :STSSwapNextVisual)
                                           "STS::[N]Swap"]
                                       :V [#(vim.cmd :STSSwapPrevVisual)
                                           "STS::[P]Swap"]
                                       :<Esc> [#(print :Exiting) :Exit true]}}
                                  {:prefix ";"} 4))

; Go faster, wagie! ;;
; (nyoom-module-p! go
;                  (do
;                    (fn go-hydra []
;                      (hydra-key! :n
;                                  {:G {:hydra true
;                                       :name "Go:: Coding"
;                                       :config {:color :teal
;                                                :hint {:border :solid
;                                                       :position :middle-right}
;                                                :invoke_on_body true}
;                                       :a [#(vim.cmd :GoCodeAction) "Add tags"]
;                                       :e [#(vim.cmd :GoIfErr) "Add if err"]
;                                       :i [#(vim.cmd :GoToggleInlay)
;                                           "Toggle inlay"]
;                                       :l [#(vim.cmd :GoLint) "Run linter"]
;                                       :o [#(vim.cmd :GoPkgOutline) :Outline]
;                                       :r [#(vim.cmd :GoRun) :Run]
;                                       :s [#(vim.cmd :GoFillStruct)
;                                           "Autofill struct"
;                                           {:prefix :<leader>}
;                                           1]}})
;                      (hydra-key! :n
;                                  {:fh {:name "Go:: Helpers"
;                                        :a [#(vim.cmd :GoAddTag)
;                                            "Add tags to struct"]
;                                        :r [#(vim.cmd :GoRMTag)
;                                            "Remove tags to struct"]
;                                        :c [#(vim.cmd :GoCoverage)
;                                            "Test coverage"]
;                                        :g [#(vim.cmd "lua require('go.comment').gen()")
;                                            "Generate comment"]
;                                        :v [#(vim.cmd :GoVet) "Go vet"]
;                                        :t [#(vim.cmd :GoModTidy) "Go mod tidy"]
;                                        :i [#(vim.cmd :GoModInit) "Go mod init"]}}
;                                  {:prefix :<leader>})
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
;                              (autocmd! FileType :*.go `(go-hydra)))))

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

(values hIndex)
