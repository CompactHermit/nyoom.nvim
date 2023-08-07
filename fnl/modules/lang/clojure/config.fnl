(local {: add_language_extension} (require :nvim-paredit.lang))
(setup :nvim-paredit {:cursor_behaviour :auto})

(local extend (add_language_extension {:commonlisp {}
                                       :fennel {}
                                       :racket {}}))
