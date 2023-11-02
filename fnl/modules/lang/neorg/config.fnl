(import-macros {: packadd! : nyoom-module-p! : nyoom-module-ensure!} :macros)

;; conditional modules

(local neorg-modules
       {:core.defaults {}
        :core.esupports.indent {:config {:dedent_excess true
                                         :format_on_escape true
                                         :format_on_enter true}}
        :core.ui {}
        :core.integrations.telescope {}
        :external.exec {}
        :core.summary {:config {:strategy :default}}
        :core.tempus {}
        :core.keybinds {:config {:default_keybinds true
                                 :neorg_leader "<leader>n"
                                 :hook (fn [keybinds]
                                         (keybinds.map :norg :n "]s" "<cmd>Neorg keybind norg core.integrations.treesitter.next.heading<cr>")
                                         (keybinds.map :norg :n "[s" "<cmd>Neorg keybind norg core.integrations.treesitter.previous.heading<cr>")
                                         (keybinds.map :norg :n "gj" "<cmd> Neorg keybind norg core.manoeuvre.item_down<cr>")
                                         (keybinds.map :norg :n "gk" "<cmd> Neorg keybind norg core.manoeuvre.item_up<cr>"))}}
        :core.dirman {:config {:workspaces {:main "~/neorg"
                                            :Math "~/neorg/Math"
                                            :NixOS "~/neorg/nixDocs"
                                            :Chess "~/neorg/Chess"
                                            :Programming "~/neorg/CS"
                                            :Academic_Math "~/neorg/Papers/Math"
                                            :Academic_CS "~/neorg/Papers/CS"
                                            :Linuxopolis "~/neorg/linux"}
                               :autodetect true
                               :autochdir true}}})


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

(nyoom-module-p! neorg.+roam
                 (tset neorg-modules :core.integrations.roam
                       {:config
                       ;; Note:: wait for PR to merge for adding keybind descriptors
                        {:keymaps {:select_prompt "<c-space>"
                                   :insert_link "<leader>ncl"
                                   :find_note "<leader>ncf"
                                   :capture_note "<leader>ncn"
                                   :capture_index "<leader>nci"
                                   :capture_cancel "<C-q>"
                                   :capture_save "<C-w>"}
                       ;; Telescope theme
                         :theme :ivy
                         :capture_templates [{:name "default"
                                              :title "${title}"
                                              :lines [""]}
                                             {:name "Math notes:: Theorem/Lemma"
                                              :title "${title}"
                                              :file "Math/${title}"
                                              :lines ["*.${heading1}::" "$.${Latex_Symbol}$"]}
                                             {:name "Capture Def"
                                              :title "$title"
                                              :lines ["$$ ${def1}" "${def1}::" "$$"]}
                                             {:name "Nix notes"
                                              :file "nixDocs/${title}"
                                              :title "${title}"
                                              :lines ["* ${heading1}::" "* ${heading2}"]}]
                         :substitution {:title (fn [metadata]
                                                 metadata.title)
                                        :date (fn [metadata]
                                                (os.date "%Y-%m-%d"))}}}))

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


(setup :neorg {:load neorg-modules})

