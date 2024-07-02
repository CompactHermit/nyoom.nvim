(import-macros {: lzn!} :macros)

;(nyoom-module! ui.dashboard)

(lzn! :alpha {:nyoom-module ui.dashboard
              :cmd [:Alpha :AlphaRedraw]
              :event :UIEnter})

; (lzn! :dashboard {:nyoom-module ui.dashboard
;                   :cmd [:Dashboard]
;                   :event :VimEnter})
