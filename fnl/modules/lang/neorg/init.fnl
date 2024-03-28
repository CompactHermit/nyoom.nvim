(import-macros {: use-package! : nyoom-module!} :macros)

;(nyoom-module! lang.neorg)
;;:nvim-neorg/neorg
(use-package! :nvim-neorg/neorg {:nyoom-module lang.neorg
                                 :ft :norg
                                 :cmd [:Neorg]})
