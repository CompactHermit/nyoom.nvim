(import-macros {: use-package!} :macros)

(use-package! :nvim-neorg/neorg
              {:nyoom-module lang.neorg
               :ft :norg
               :cmd [:Neorg]
               :requires [(pack :laher/neorg-exec {:opt true})
                          (pack :nvim-neorg/neorg-telescope {:opt true})
                          (pack :Jarvismkennedy/neorg-roam.nvim {:opt true :branch :main})
                          (pack :3rd/image.nvim {:opt true})]})
