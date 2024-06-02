(import-macros {: lzn! : pack} :macros)

;; NOTE:: We just use the middleclass rock ourselves
(lzn! :windows
      {:event :DeferredUIEnter
       :deps [:animation]
       :after #((. (autoload :windows) :setup) {:autowidth {:enable true
                                                            :winwidth 50}
                                                :animation {:enable true
                                                            :duration 100
                                                            :fps 60}})})

(lzn! :reactive {:nyoom-module ui.animate :event :BufWritePost})

; :requires [(pack :anuvyklack/middleclass)
;            (pack :anuvyklack/animation.nvim)]})

;(lzn! :jbyuki/venn.nvim {:event [:BufWritePost]})
