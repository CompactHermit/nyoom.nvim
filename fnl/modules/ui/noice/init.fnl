(import-macros {: use-package! : nyoom-module!} :macros)

;(use-package! :folke/noice.nvim
;              {:nyoom-module ui.noice
;               ;;:after :nvim-lspconfig
;               :event :BufReadPre
;               :requires [(pack :rcarriga/nvim-notify {:opt true})]})

(nyoom-module! ui.noice)
