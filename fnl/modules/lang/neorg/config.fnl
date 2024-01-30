(import-macros {: packadd! : nyoom-module-p! : nyoom-module-ensure!} :macros)

;; conditional modules
(packadd! :neorg-exec)
(packadd! :neorg-telescope)
(packadd! :neorg-timelog)
(packadd! :neorg-hop-extras)
(fn neorg_leader [key]
  (.. :<leader>n key))

(local neorg-modules
       {:core.defaults {}
        :core.esupports.indent {:config {:dedent_excess true
                                         :format_on_escape true
                                         :format_on_enter true}}
        :core.ui {}
        :core.integrations.telescope {}
        :external.exec {}
        :external.timelog {}
        ;; NOTE:: (Hemrit) Only until janet has been added
        :external.hop-extras {:config {:aliases {:gh "https://github.com/{}"}}}
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
        :core.ui.calendar {}
        :core.integrations.image {}
        :core.latex.renderer {}
        :core.keybinds {:config {:default_keybinds true
                                 :neorg_leader :<leader>n
                                 :hook (fn [keybinds]
                                         (keybinds.map_event_to_mode :norg
                                                                     {:n [[(neorg_leader :lt)
                                                                           :core.integrations.telescope.find_aof_tasks]
                                                                          [(neorg_leader :lc)
                                                                           :core.integrations.telescope.find_context_tasks]
                                                                          [(neorg_leader :in)
                                                                           :core.itero.next-iteration]
                                                                          [(neorg_leader :ip)
                                                                           :core.itero.next-iteration]
                                                                          [:gk
                                                                           :core.manoeuvre.item_up]
                                                                          [:gk
                                                                           :core.manoeuvre.item_down]
                                                                          [:<Tab>
                                                                           :core.integrations.treesitter.next.link]
                                                                          [:<S-Tab>
                                                                           :core.integrations.treesitter.previous.link]
                                                                          ["]]"
                                                                           :core.integrations.treesitter.next.heading]
                                                                          ["[["
                                                                           :core.integrations.treesitter.previous.heading]]}
                                                                     {:noremap true
                                                                      :silent true})
                                         (keybinds.map_to_mode :norg
                                                               {:n [[(neorg_leader :li)
                                                                     "<cmd>Neorg timelog insert *<cr>"]]}
                                                               {:noremap true
                                                                :silent true}))}}
        :core.dirman {:config {:workspaces {:main "~/neorg"
                                            :Math "~/neorg/Math"
                                            :NixOS "~/neorg/nixDocs"
                                            :Chess "~/neorg/Chess"
                                            :Programming "~/neorg/CS"
                                            :Academic_Math "~/neorg/Papers/Math"
                                            :Academic_CS "~/neorg/Papers/CS"
                                            :Linuxopolis "~/neorg/linux"}
                               :default_workspace :main}}})

;; add conditional modules
(nyoom-module-p! cmp (tset neorg-modules :core.completion
                           {:config {:engine :nvim-cmp}}))

;; add flaged modules
(nyoom-module-p! neorg.+pretty
                 (tset neorg-modules :core.concealer
                       {:config {:folds true
                                 :icon_preset :varied
                                 :icons {:code_block {:conceal true
                                                      :padding {:left 1
                                                                :right 3}}
                                         :todo {:done {:icon ""}
                                                :pending {:icon ""}}}}}))

(packadd! :neorg-roam.nvim)
(nyoom-module-p! neorg.+roam
                 (do
                   (packadd! :neorg-roam.nvim)
                   (tset neorg-modules :core.integrations.roam
                         {:config {:keymaps {:select_prompt :<c-space>
                                             :insert_link :<leader>ncl
                                             :find_note :<leader>ncf
                                             :capture_note :<leader>ncn
                                             :capture_index :<leader>nci
                                             ; :get_backlinks :<leader>ncb
                                             ; :db_sync :<leader>ncd
                                             ; :db_sync_wksp :<leader>ncw
                                             :capture_cancel :<C-q>
                                             :capture_save :<C-w>}
                                   :theme :ivy
                                   ;:workspaces [:main :NixOS :Programming]
                                   :capture_templates [{:name :default
                                                        :title "${title}"
                                                        :lines [""]}
                                                       {:name "Math notes:: Theorem/Lemma"
                                                        :title "${title}"
                                                        :file "Math/${title}"
                                                        :lines ["*.${heading1}::"
                                                                "$.${Latex_Symbol}$"]}
                                                       {:name "Capture Def"
                                                        :title :$title
                                                        :lines ["$$ ${def1}"
                                                                "${def1}::"
                                                                "$$"]}
                                                       {:name "Nix notes"
                                                        :file "nixDocs/${title}"
                                                        :title "${title}"
                                                        :lines ["* ${heading1}::"
                                                                "* ${heading2}"]}]
                                   :substitution {:title (fn [metadata]
                                                           metadata.title)
                                                  :date (fn [metadata]
                                                          (os.date "%Y-%m-%d"))}}})))

(nyoom-module-p! neorg.+present
                 (do
                   (nyoom-module-ensure! zen)
                   (tset neorg-modules :core.presenter
                         {:config {:zen_mode :truezen}})))

(nyoom-module-p! neorg.+export
                 (do
                   (tset neorg-modules :core.export {})
                   (tset neorg-modules :core.export.markdown
                         {:config {:extensions :all}})))

(packadd! image.nvim)
((->> :setup
      (. (require :image))) {:backend :kitty
                                          :integrations {:markdown {:enabled true
                                                                    :download_remote_images true
                                                                    :filetypes [:markdown
                                                                                :quarto
                                                                                :vimwiki]}
                                                         :neorg {:enabled true
                                                                 :download_remote_images true
                                                                 :clear_in_insert_mode false
                                                                 :only_render_image_at_cursor false
                                                                 :filetypes [:norg]}}})

(setup :neorg {:load neorg-modules})
