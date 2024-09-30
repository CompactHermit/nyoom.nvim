(import-macros {: use-package!} :macros)

(use-package! :tjdevries/ocaml.nvim
              {:opt true :ft [:ml :ocaml] :call-setup ocaml})
