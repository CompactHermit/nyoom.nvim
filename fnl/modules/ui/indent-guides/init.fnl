(import-macros {: lzn!} :macros)

(lzn! :hlchunks {:nyoom-module ui.indent-guides
                 :event [:BufReadPre :BufNewFile]})

; (lzn! :ibl {:nyoom-module ui.indent-guides
;             :event [:BufReadPost :BufAdd :BufNewFile]})
