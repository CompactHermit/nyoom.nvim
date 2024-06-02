(import-macros {: lzn!} :macros)

;(nyoom-module! ui.dashboard)

(lzn! :alpha {:nyoom-module ui.dashboard
              :cmd [:Alpha :AlphaRedraw]
              :event :VimEnter})
