(import-macros {: use-package! : nyoom-module!} :macros)

;(nyoom-module! lang.neorg)
;;:nvim-neorg/neorg
(use-package! :nvim-neorg/neorg
              {:nyoom-module lang.neorg
               :ft :norg
               :cmd [:Neorg]
               :requires [(pack :laher/neorg-exec {:opt true})
                          (pack :Jarvismkennedy/neorg-roam.nvim
                                {:opt true :branch :main})
                          (pack :phenax/neorg-timelog {:opt true})
                          (pack :phenax/neorg-hop-extras {:opt true})
                          (pack :3rd/image.nvim {:opt true})]})
