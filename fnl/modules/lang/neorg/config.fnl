(import-macros {: packadd! : nyoom-module-p! : nyoom-module-ensure!} :macros)

;; conditional modules

(local neorg-modules
       {:core.defaults {}
        :core.manoeuvre {}
        :core.ui {}
        :external.codecap {}
        :core.ui.calendar {}
        :core.summary {:config {:strategy :metadata}}
        :core.ui.calendar.views.monthly {}
        :core.tempus {}
        :core.keybinds {:config {:default_keybinds true
                                 :neorg_leader "<leader>n"}}
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
                       {:config {:icon_preset :varied
                                 :folds true
                                 :dim_code_blocks {:width :content}}}))

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
