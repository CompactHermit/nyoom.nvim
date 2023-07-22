(import-macros {: packadd! : nyoom-module-p! : nyoom-module-ensure!} :macros)

;; conditional modules

(local neorg-modules
       {:core.defaults {}
        :core.manoeuvre {}
        :core.ui {}
        :core.integrations.telescope {}
        :external.codecap {}
        :external.exec {}
        :core.ui.calendar {}
        :core.summary {:config {:strategy :metadata}}
        :core.ui.calendar.views.monthly {}
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
                                            :Academic_CS "~/neorg/Papers/CS"}
                               :autodetect true
                               :autochdir true}}})
        ;;:external.templates {:config {:templates_dir (.. (vim.fn.stdpath :config) :/templates/norg)}}})


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

;;TODO:: refactor this to be faster, rn just adding it into ./init.fnl is faster, but that should't make sense(?)
; (nyoom-module-p! neorg.+Inbox
;                  (do
;                    (tset neorg-modules :external.codecap {})))

(setup :neorg {:load neorg-modules})

