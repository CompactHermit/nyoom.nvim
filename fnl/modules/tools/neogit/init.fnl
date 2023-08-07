(import-macros {: use-package!} :macros)

; Magit for neovim
(use-package! :NeogitOrg/neogit
              {:nyoom-module tools.neogit 
               :cmd [:Neogit]})
