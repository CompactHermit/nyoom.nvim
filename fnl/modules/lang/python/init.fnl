(import-macros {: use-package!} :macros)

;; Poetry plugin for neovim
(use-package! :vsedov/pv.nvim
              {:nyoom-module lang.python
               :ft [:python]
               :call-setup py})
