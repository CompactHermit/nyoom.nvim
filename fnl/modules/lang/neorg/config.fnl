(import-macros {: packadd! : nyoom-module-p! : autocmd! : nyoom-module-ensure!}
               :macros)

(local neorg-modules
       {:core.defaults {}
        :core.text-objects {}
        :core.esupports.metagen {:config {:type :false}}
        :core.esupports.indent {:config {:dedent_excess true
                                         :format_on_escape true
                                         :format_on_enter true}}
        :core.ui {}
        :core.todo-introspector {}
        :core.integrations.telescope {}
        :external.exec {}
        :core.qol.toc {:config {:enter true
                                :fixed_width 26
                                :auto_toc {:open false :close true}}}
        :external.conceal-wrap {}
        :external.interim-ls {:config {:completion_provider {:enable true
                                                             :categories true}}}
        :external.search {:config {:index_on_launch true}}
        :external.templates {:config {:templates_dir (.. vim.env.HOME
                                                         :/neorg/templates)
                                      :snippets_overwrite {}
                                      :default_subcommand :load
                                      :keywords {:TODAY_TITLE #(print :hello)
                                                 :YESTERDAY_PATH #(print :hello)
                                                 :TOMORROW_PATH #(print :hello)}}}
        ;:CARRY_OVER_TODOS #(print :hello)}}}
        ;; NOTE:: (Hemrit) Only until janet has been added
        ; :external.hop-extras {:config {:aliases {:gh "https://github.com/{}"}}} #Keybind issue
        ; :external.timelog {}
        ; :external.chronicle {:config {:workspace :main
        ;                               :directory :chronicle
        ;                               :modes {:daily {:path_format ["%Y"
        ;                                                             "%m-%B"
        ;                                                             "%d-%A"
        ;                                                             :daily.norg]}}
        ;                               :daily {:template_path ["%Y"
        ;                                                       "%m-%B"
        ;                                                       "%d-%A"
        ;                                                       :daily.norg]}
        ;                               :weekly {:template_path ["%Y"
        ;                                                        "%m-%B"
        ;                                                        "%W"
        ;                                                        :weekly.norg]}
        ;                               :monthly {:template_path ["%Y"
        ;                                                         "%m-%B"
        ;                                                         :monthly.norg]}
        ;                               :quarterly {:template_path ["%Y"
        ;                                                           "%Q"
        ;                                                           :quarterly.norg]}
        ;                               :yearly {:template_path ["%Y"
        ;                                                        :yearly.norg]}}}
        :core.summary {:config {:strategy :default}}
        :core.tempus {}
        ;; NOTE:: Broken Bcs Vhyrro hates us all, jk the calendar keybinds are broken
        :core.ui.calendar {}
        :core.integrations.image {}
        :core.latex.renderer {}
        :core.keybinds {:config {:default_keybinds true}}
        :core.dirman {:config {:workspaces {:main "~/neorg"
                                            :Math "~/neorg/Papers/Math"
                                            :NixOS "~/neorg/nixDocs"
                                            :Chess "~/neorg/Chess"
                                            :Programming "~/neorg/CS"
                                            :Math "~/neorg/Papers/Math"
                                            :CS "~/neorg/Papers/CS"
                                            :Linuxopolis "~/neorg/linux"}
                               :default_workspace :main}}})

;; add conditional modules
(tset neorg-modules :core.completion
      {:config {:engine {:module_name :external.lsp-completion}}})

(nyoom-module-p! quarto
                 (tset neorg-modules :core.integrations.otter
                       {:config {:auto_start false
                                 :languages [:python
                                             :lua
                                             :nix
                                             :haskell
                                             :rust
                                             :julia]}}))

(nyoom-module-p! neorg.+agenda
                 (do
                   (-> (vim.iter [:external.agenda :external.roam])
                       (: :each #(tset neorg-modules $1 {}))))
                 (tset neorg-modules :external.many-mans.meta-man
                       {:config {:treesitter_fold false}}))

;; add flaged modules
(tset neorg-modules :core.concealer
      {:config {:folds true
                :icon_preset :varied
                :icons {:code_block {:conceal true :padding {:left 1 :right 3}}
                        :todo {:done {:icon ""}
                               :pending {:icon ""}
                               :urgent {:icon ""}}}}})

;; https://github.com/nvim-neorg/neorg/wiki/Default-Keybinds
;; REFACTOR:: NEW KEYBINDS, which use plug and laziness
;; TODO:: (hermit) make `neorg-leader` macro, of form `(fn [modname mode opts])` and set keybinds that way
(vim.api.nvim_create_autocmd :BufEnter
                             {:pattern :*.norg
                              :once true
                              :callback (fn [ctx]
                                          (doto :i
                                            (vim.keymap.set :<S-CR>
                                                            "<Plug>(neorg.esupports.hop.hop-link)"
                                                            {:buffer true}))
                                          (doto :n
                                            ;; Neorg-se Keymaps
                                            (vim.keymap.set :<leader>nsf
                                                            "<Plug>(neorg.search.fulltext)")
                                            (vim.keymap.set :<leader>nsc
                                                            "<Plug>(neorg.search.categories)")
                                            (vim.keymap.set :<leader>nsu
                                                            "<Plug>(neorg.search.index_update)")
                                            (vim.keymap.set :<leader>nlt
                                                            "<Plug>(neorg.telescope.find_linkable)"
                                                            {:buffer true})
                                            (vim.keymap.set :<leader>nlt
                                                            "<Plug>(neorg.telescope.find_linkable)"
                                                            {:buffer true})
                                            (vim.keymap.set :<leader>nlw
                                                            "<Plug>(neorg.telescope.switch_workspace)"
                                                            {:buffer true})
                                            (vim.keymap.set :<leader>nlh
                                                            "<Plug>(neorg.telescope.search_heading)"
                                                            {:buffer true})
                                            (vim.keymap.set :<leader>nlb
                                                            "<Plug>(neorg.telescope.find_header_backlinks)"
                                                            {:buffer true})))})

;                                  :core.integrations.telescope.find_aof_tasks]
;                                 [(neorg_leader :lc)
;                                  :core.integrations.telescope.find_context_tasks]
;                                 [(neorg_leader :lh)
;                                  :core.integrations.telescope.find_header_backlinks]
;                                 [(neorg_leader :lb)
;                                  :core.integrations.telescope.find_backlinks]
;                                 [(neorg_leader :in)
;                                  :core.itero.next-iteration]
;                                 [(neorg_leader :ip)
;                                  :core.itero.next-iteration]
;                                 [:gk
;                                  :core.manoeuvre.item_up]
;                                 [:gk
;                                  :core.manoeuvre.item_down]
;                                 [:<Tab>
;                                  :core.integrations.treesitter.next.link]
;                                 [:<S-Tab>
;                                  :core.integrations.treesitter.previous.link]
;                                 ["]]"
;                                  :core.integrations.treesitter.next.heading]
;                                 ["[["
;                                  :core.integrations.treesitter.previous.heading]]}
;                            {:noremap true
;                             :silent true}
; (keybinds.map_to_mode :norg
;                       {:n [[(neorg_leader :li)
;                             "<cmd>Neorg timelog insert *<cr>"]]}
;                       {:noremap true
;                        :silent true}))
;
;

; (do
;   (tset neorg-modules :core.integrations.roam
;         {:config {:keymaps {:select_prompt :<c-space>
;                             :insert_link :<leader>ncl
;                             :find_note :<leader>ncf
;                             :capture_note :<leader>ncn
;                             :capture_index :<leader>nci
;                             ; :get_backlinks :<leader>ncb
;                             ; :db_sync :<leader>ncd
;                             ; :db_sync_wksp :<leader>ncw
;                             :capture_cancel :<C-q>
;                             :capture_save :<C-w>}
;                   :theme :ivy
;                   ;:workspaces [:main :NixOS :Programming]
;                   :capture_templates [{:name :default
;                                        :title "${title}"
;                                        :lines [""]}
;                                       {:name "Math notes:: Theorem/Lemma"
;                                        :title "${title}"
;                                        :file "Math/${title}"
;                                        :lines ["*.${heading1}::"
;                                                "$.${Latex_Symbol}$"]}
;                                       {:name "Capture Def"
;                                        :title :$title
;                                        :lines ["$$ ${def1}" "${def1}::" "$$"]}
;                                       {:name "Nix notes"
;                                        :file "nixDocs/${title}"
;                                        :title "${title}"
;                                        :lines ["* ${heading1}::"
;                                                "* ${heading2}"]}]
;                   :substitution {:title (fn [metadata]
;                                           metadata.title)
;                                  :date (fn [metadata]
;                                          (os.date "%Y-%m-%d"))}}}))

(nyoom-module-p! zen (tset neorg-modules :core.presenter
                           {:config {:zen_mode :truezen}}))

(nyoom-module-p! neorg.+export
                 (do
                   (tset neorg-modules :core.export {})
                   (tset neorg-modules :core.export.markdown
                         {:config {:extensions :all}})))

;;TODO:: (Hemrit) Properly add dep-Support with lz.n

;; fnlfmt: skip
(let [fidget (require :fidget)
      nio (require :nio)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :neorg}})]
   (progress:report {:message "PackStrapping <Neorg-Deps>"
                     :level vim.log.levels.ERROR
                     :progress 0})
   (progress:report {:message "Initializing Neorg"
                         :level vim.log.levels.ERROR
                         :progress 20})
   ((->> :setup (. (require :neorg))) {:load neorg-modules})
   (progress:report {:message "<Neorg> Setup Complete!"
                     :title :Completed!
                     :progress 99})
   (progress:finish))
