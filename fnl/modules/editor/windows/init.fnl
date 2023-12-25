(import-macros {: use-package!} :macros)

;; Window animation, For the obsidian feel::
(use-package! :folke/edgy.nvim
              {:nyoom-module editor.windows :opt true :event [:BufReadPost]})

;; NOTE:: This is just a glorified Folkes worship config. I need to rework these, by a lonnnng shot, fml
(use-package! :folke/trouble.nvim {:opt true :cmd :Trouble :call-setup trouble})

(use-package! :folke/todo-comments.nvim
              {:opt true
               :cmd [:TodoTrouble :TodoTelescope :TodoLocList :TodoQuickFix]
               :config (fn []
                         ((->> :setup
                               (. (require :todo-comments))) {:keywords {:REFACTOR {:icon "󰷦 "
                                                                                                                          :color "#2563EB"
                                                                                                                          :alt [:REF
                                                                                                                                :REFCT
                                                                                                                                :REFACT]}}}))})
