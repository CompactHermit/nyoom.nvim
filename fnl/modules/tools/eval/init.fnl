(import-macros {: use-package!} :macros)

;; interactive lisp evaluation
(use-package! :Olical/conjure
              {:nyoom-module tools.eval :branch :develop :event :BufReadPost})

; :ft [:clojure
;      :lisp
;      :janet
;      :rust
;      :lua
;      :julia
;      :python]})
