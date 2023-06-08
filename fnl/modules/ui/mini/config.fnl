(import-macros {: nyoom-module-p!} :macros)

;; NOTE: IDK if Mini has a way to handle it's modules like Neorg
 ;; My assumption is they don't.
;; FIXME: Mini is broken

;;Load Mini Libraries,
(nyoom-module-p! mini
                 (do
                   (setup :mini.animate)
                   (setup :mini.map)))
