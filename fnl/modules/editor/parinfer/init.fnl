(import-macros {: lzn! : let!} :macros)

;
(lzn! :nvim-parinfer 
      {:nyoom-module editor.parinfer
                 :ft [:clojure
                       :carp
                       :scheme
                       :lisp
                       :racket
                       :hy
                       :fennel
                       :janet
                       :carp
                       :wast
                       :yuck]
                 :before (fn []
                          (tset vim.g :parinfer_enabled true)
                          (tset vim.g :parinfer_bi_maps true)
                          (tset vim.g :parinfer_filetypes
                                [:clojure
                                 :carp
                                 :scheme
                                 :lisp
                                 :racket
                                 :hy
                                 :fennel
                                 :janet
                                 :carp
                                 :wast
                                 :yuck])
                          )})
