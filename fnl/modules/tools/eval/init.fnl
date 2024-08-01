(import-macros {: lzn!} :macros)

;; interactive lisp evaluation
(lzn! :conjure
      {:nyoom-module tools.eval
       :cmd [:ConjureEval :ConjureEvalBuf]
       :ft [:clojure :lisp :janet :rust :lua :fennel :julia :python]})
