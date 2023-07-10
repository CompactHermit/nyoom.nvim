(import-macros {: use-package!} :macros)

;; Poetry plugin for neovim
(use-package! :AckslD/swenv.nvim
              {:nyoom-module lang.python
               :ft [:python]
               :cmd ["VenvFind" "GetVenv"]})

