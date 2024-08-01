(import-macros {: lzn! : let!} :macros)

;
(lzn! :nvim-parinfer {:nyoom-module editor.parinfer
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
                      :before #(doto vim.g
                                 (tset :parinfer_enabled true)
                                 (tset :parinfer_no_maps true)
                                 (tset :parinfer_filetypes
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
                                        :yuck]))})
