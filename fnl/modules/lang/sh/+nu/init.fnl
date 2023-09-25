(import-macros {: use-package!} :macros)

(use-package! :LhKipp/nvim-nu
             {:nyoom-module lang.sh.+nu
              :opt true
              :ft [:nu]
              :call-setup nu})
