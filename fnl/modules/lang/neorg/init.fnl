(import-macros {: use-package!} :macros)

(use-package! :nolbap/neorg {:nyoom-module lang.neorg 
                             :ft :norg 
                             :cmd :Neorg
                             :requires [ :laher/neorg-codecap
                                         (pack :laher/neorg-exec)
                                         (pack :nvim-neorg/neorg-telescope)
                                         :pysan3/neorg-templates]})
;; TODO:; add +template module
; (use-package! :pysan3/neorg-templates
;               {:dependencies [:L3MON4D3/LuaSnip]})

