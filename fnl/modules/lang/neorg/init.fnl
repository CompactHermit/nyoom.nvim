(import-macros {: use-package!} :macros)

(use-package! :nvim-neorg/neorg {:nyoom-module lang.neorg 
                                 :ft :norg 
                                 :cmd :Neorg
                                 :requires [(pack :laher/neorg-exec)
                                            (pack :nvim-neorg/neorg-telescope)
                                            (pack :Jarvismkennedy/neorg-roam.nvim)]})
;; TODO:; add +template module
; (use-package! :pysan3/neorg-templates
;               {:dependencies [:L3MON4D3/LuaSnip]})

