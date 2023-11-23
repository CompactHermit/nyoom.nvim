(import-macros {: use-package!} :macros)

(use-package! :p00f/clangd_extensions.nvim
              {:nyoom-module lang.cc :ft [:c :cpp]})

(use-package! :v1nh1shungry/cppreference.nvim
              {:opt true
               :ft [:cpp :c]
               :config (fn []
                         (local {: setup} (require :cppreference))
                         (setup {:view :cppman
                                 :cppman {:position :split}}))})

