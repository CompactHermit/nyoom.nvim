(import-macros {: lzn!} :macros)

(lzn! :bufferline {:nyoom-module ui.tabs
                   :cmd [:BufferLine]
                   :event [:DeferredUIEnter]})

(lzn! :grug {:cmd [:GrugFar]
             :keys [{1 :<M-r>
                     2 #((. (require :grug-far) :grug_far))
                     :desc "[Gr]ug [F]ar"}]
             :call-setup grug-far})

;; Faux Buffer Control, with better defaults
(lzn! :bufferControl {:cmd [:BufferControl] :load (fn []) :after (fn [])})
